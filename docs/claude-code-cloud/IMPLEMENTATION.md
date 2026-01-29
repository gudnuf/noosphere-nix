# Implementation Guide

## Phase 1: Core Infrastructure

**Goal:** Create the Nix modules and host configuration for cloud instances.

### 1.1 Create cloud-instance module

Create `modules/nixos/cloud-instance.nix` with options for:
- `userSshKey` - User's SSH public key
- `instanceId` - Unique instance identifier
- `expiresAt` - Optional expiration timestamp

### 1.2 Create cloud-instance host

Create `hosts/cloud-instance/` directory:
- `default.nix` - Minimal config, no hardcoded SSH keys
- `hardware-configuration.nix` - Copy from hetzner (QEMU/KVM)
- `networking.nix` - DHCP-based (not static IPs)

### 1.3 Modify flake.nix

Add `mkCloudInstance` helper function that:
- Takes `instanceId` and `userSshKey` as parameters
- Sets hostname to `cc-${instanceId}`
- Enables the cloud-instance module with provided values

### 1.4 Test manually

```bash
# Build a test configuration
nix build .#nixosConfigurations.cloud-instance.config.system.build.toplevel

# Verify it builds without errors
```

---

## Phase 2: Provisioning Automation

**Goal:** Create scripts to automate server provisioning and teardown.

### 2.1 Create state management helpers

Create `scripts/cloud/lib/state.sh`:

```bash
#!/usr/bin/env bash

STATE_DIR="${STATE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../../state}"
STATE_FILE="$STATE_DIR/instances.json"

init_state() {
  mkdir -p "$STATE_DIR"
  [[ -f "$STATE_FILE" ]] || echo '{"instances":{}}' > "$STATE_FILE"
}

add_instance() {
  local id="$1" email="$2" name="$3" ip="$4" type="$5" expires="$6"
  local now=$(date -Iseconds)

  jq --arg id "$id" \
     --arg email "$email" \
     --arg name "$name" \
     --arg ip "$ip" \
     --arg type "$type" \
     --arg created "$now" \
     --arg expires "$expires" \
     '.instances[$id] = {
       instanceId: $id,
       email: $email,
       serverName: $name,
       serverIp: $ip,
       serverType: $type,
       createdAt: $created,
       expiresAt: $expires,
       status: "running"
     }' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

remove_instance() {
  local id="$1"
  jq --arg id "$id" 'del(.instances[$id])' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

get_instance() {
  local id="$1"
  jq -r --arg id "$id" '.instances[$id]' "$STATE_FILE"
}

list_instances() {
  jq -r '.instances | to_entries[] | "\(.key)\t\(.value.serverIp)\t\(.value.email)\t\(.value.expiresAt)"' "$STATE_FILE"
}

get_expired() {
  local now=$(date -Iseconds)
  jq -r --arg now "$now" '.instances | to_entries[] | select(.value.expiresAt < $now) | .key' "$STATE_FILE"
}
```

### 2.2 Create provision.sh

Create `scripts/cloud/provision.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/state.sh"

# Defaults
DEFAULT_TYPE="cpx21"
DEFAULT_HOURS=24
DEFAULT_LOCATION="fsn1"

usage() {
  cat <<EOF
Usage: $(basename "$0") <email> <ssh-pubkey> [hours] [server-type]

Arguments:
  email        User's email address
  ssh-pubkey   User's SSH public key (ed25519 or RSA)
  hours        Hours until expiration (default: $DEFAULT_HOURS)
  server-type  Hetzner server type (default: $DEFAULT_TYPE)
                 cpx11 - 2 vCPU, 2GB RAM
                 cpx21 - 3 vCPU, 4GB RAM
                 cpx31 - 4 vCPU, 8GB RAM
EOF
  exit 1
}

[[ $# -lt 2 ]] && usage

EMAIL="$1"
SSH_KEY="$2"
HOURS="${3:-$DEFAULT_HOURS}"
SERVER_TYPE="${4:-$DEFAULT_TYPE}"

# Validate SSH key format
if [[ ! "$SSH_KEY" =~ ^ssh-(ed25519|rsa) ]]; then
  echo "Error: Invalid SSH key format. Must be ed25519 or RSA."
  exit 1
fi

# Generate instance ID
INSTANCE_ID=$(openssl rand -hex 6)
SERVER_NAME="cc-$INSTANCE_ID"
EXPIRES_AT=$(date -d "+${HOURS} hours" -Iseconds)

echo "Provisioning Claude Code Cloud instance..."
echo "  Instance ID: $INSTANCE_ID"
echo "  Server type: $SERVER_TYPE"
echo "  Expires: $EXPIRES_AT"

# Initialize state
init_state

# Create Hetzner server
echo "Creating Hetzner server..."
hcloud server create \
  --name "$SERVER_NAME" \
  --type "$SERVER_TYPE" \
  --image ubuntu-24.04 \
  --location "$DEFAULT_LOCATION" \
  --ssh-key operator-key

# Get server IP
SERVER_IP=$(hcloud server describe "$SERVER_NAME" -o format='{{.PublicNet.IPv4.IP}}')
echo "Server IP: $SERVER_IP"

# Wait for SSH
echo "Waiting for SSH..."
for i in {1..30}; do
  if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o BatchMode=yes "root@$SERVER_IP" exit 2>/dev/null; then
    break
  fi
  sleep 5
done

# Deploy NixOS
echo "Deploying NixOS..."
# TODO: Implement nixos-anywhere deployment with dynamic SSH key

# Update state
add_instance "$INSTANCE_ID" "$EMAIL" "$SERVER_NAME" "$SERVER_IP" "$SERVER_TYPE" "$EXPIRES_AT"

echo ""
echo "Instance provisioned successfully!"
echo "=================================="
echo "Instance ID: $INSTANCE_ID"
echo "SSH command: ssh claude@$SERVER_IP"
echo "Expires:     $EXPIRES_AT"
```

### 2.3 Create deprovision.sh

Create `scripts/cloud/deprovision.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/state.sh"

[[ $# -lt 1 ]] && { echo "Usage: $(basename "$0") <instance-id>"; exit 1; }

INSTANCE_ID="$1"
INSTANCE=$(get_instance "$INSTANCE_ID")

if [[ "$INSTANCE" == "null" ]]; then
  echo "Error: Instance $INSTANCE_ID not found"
  exit 1
fi

SERVER_NAME=$(echo "$INSTANCE" | jq -r '.serverName')

echo "Deprovisioning instance $INSTANCE_ID..."

# Delete Hetzner server
if hcloud server describe "$SERVER_NAME" &>/dev/null; then
  hcloud server delete "$SERVER_NAME"
  echo "Server deleted"
else
  echo "Server not found in Hetzner (already deleted?)"
fi

# Remove from state
remove_instance "$INSTANCE_ID"
echo "Instance removed from state"

echo "Done"
```

### 2.4 Test provision/deprovision cycle

```bash
export HCLOUD_TOKEN="..."
./scripts/cloud/provision.sh test@example.com "ssh-ed25519 AAAA..." 1 cpx11
./scripts/cloud/deprovision.sh <instance-id>
```

---

## Phase 3: Lifecycle Management

**Goal:** Add expiration checking and time extension.

### 3.1 Create check-expired.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/state.sh"

init_state

for instance_id in $(get_expired); do
  echo "Deprovisioning expired instance: $instance_id"
  "$SCRIPT_DIR/deprovision.sh" "$instance_id"
done
```

### 3.2 Create extend.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/state.sh"

[[ $# -lt 2 ]] && { echo "Usage: $(basename "$0") <instance-id> <hours>"; exit 1; }

INSTANCE_ID="$1"
HOURS="$2"

# Update expiration in state file
NEW_EXPIRES=$(date -d "+${HOURS} hours" -Iseconds)
jq --arg id "$INSTANCE_ID" --arg expires "$NEW_EXPIRES" \
   '.instances[$id].expiresAt = $expires' \
   "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

echo "Extended instance $INSTANCE_ID by $HOURS hours"
echo "New expiration: $NEW_EXPIRES"
```

### 3.3 Set up cron job

Add to crontab:
```
0 * * * * /path/to/noosphere-nix/scripts/cloud/check-expired.sh
```

---

## Phase 4: CLI Interface

**Goal:** Create user-friendly CLI wrapper.

### 4.1 Create ccc CLI

Create `scripts/cloud/ccc`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Claude Code Cloud CLI

Usage: ccc <command> [options]

Commands:
  provision   Create a new instance
  deprovision Delete an instance
  status      Check instance status
  list        List all instances
  extend      Extend instance time
  types       Show available server types

Run 'ccc <command> --help' for command-specific help.
EOF
}

case "${1:-}" in
  provision)
    shift
    "$SCRIPT_DIR/provision.sh" "$@"
    ;;
  deprovision)
    shift
    "$SCRIPT_DIR/deprovision.sh" "$@"
    ;;
  status)
    shift
    "$SCRIPT_DIR/status.sh" "$@"
    ;;
  list)
    "$SCRIPT_DIR/lib/state.sh" && list_instances
    ;;
  extend)
    shift
    "$SCRIPT_DIR/extend.sh" "$@"
    ;;
  types)
    echo "Available server types:"
    echo "  cpx11  2 vCPU, 2GB RAM, 40GB   ~€0.007/hr  ~€5/mo"
    echo "  cpx21  3 vCPU, 4GB RAM, 80GB   ~€0.010/hr  ~€7/mo"
    echo "  cpx31  4 vCPU, 8GB RAM, 160GB  ~€0.019/hr  ~€14/mo"
    ;;
  -h|--help|"")
    usage
    ;;
  *)
    echo "Unknown command: $1"
    usage
    exit 1
    ;;
esac
```

---

## Verification

### End-to-End Test

```bash
# 1. Export Hetzner token
export HCLOUD_TOKEN="..."

# 2. Provision test instance
./scripts/cloud/ccc provision test@example.com "ssh-ed25519 AAAA..." 1 cpx11

# 3. Verify SSH access
ssh claude@<ip>

# 4. Verify Claude Code
claude --version

# 5. Check status
./scripts/cloud/ccc status <instance-id>

# 6. List instances
./scripts/cloud/ccc list

# 7. Deprovision
./scripts/cloud/ccc deprovision <instance-id>
```
