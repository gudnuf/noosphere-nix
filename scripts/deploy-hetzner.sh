#!/usr/bin/env bash
set -euo pipefail

# deploy-hetzner.sh - Deploy NixOS to Hetzner Cloud
#
# Usage:
#   deploy-hetzner.sh <hostname> [--create] [--server-type TYPE] [--location LOC]
#
# Examples:
#   deploy-hetzner.sh hetzner --create              # Create server and deploy
#   deploy-hetzner.sh hetzner                       # Deploy to existing server
#   deploy-hetzner.sh myserver --create --server-type cx32 --location nbg1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(dirname "$SCRIPT_DIR")"

# Defaults
SERVER_TYPE="cx22"       # 2 vCPU, 4GB RAM, 40GB disk (~€4/month)
LOCATION="fsn1"          # Falkenstein, Germany
IMAGE="ubuntu-24.04"     # Base image for nixos-anywhere
SSH_KEY_NAME="claude@nous"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat <<EOF
Usage: $(basename "$0") <hostname> [options]

Deploy NixOS to a Hetzner Cloud server using nixos-anywhere.

Arguments:
  hostname        Name of the NixOS configuration (must exist in flake.nix)

Options:
  --create        Create a new server (otherwise expects existing server)
  --server-type   Hetzner server type (default: $SERVER_TYPE)
  --location      Hetzner location (default: $LOCATION)
  --help          Show this help message

Server Types:
  cx22   - 2 vCPU, 4GB RAM, 40GB disk  (~€4/month)
  cx32   - 4 vCPU, 8GB RAM, 80GB disk  (~€8/month)
  cx42   - 8 vCPU, 16GB RAM, 160GB disk (~€15/month)

Locations:
  fsn1   - Falkenstein, Germany
  nbg1   - Nuremberg, Germany
  hel1   - Helsinki, Finland
  ash    - Ashburn, USA

Prerequisites:
  1. HCLOUD_TOKEN environment variable set
  2. SSH key '$SSH_KEY_NAME' registered in Hetzner Console
  3. nixos-anywhere available (run with: nix run .#deploy-hetzner)

EOF
    exit 0
}

check_prerequisites() {
    if [[ -z "${HCLOUD_TOKEN:-}" ]]; then
        log_error "HCLOUD_TOKEN environment variable not set"
        log_info "Get a token from: https://console.hetzner.cloud/ → Project → Security → API Tokens"
        log_info "Then run: export HCLOUD_TOKEN='your_token_here'"
        exit 1
    fi

    if ! command -v hcloud &>/dev/null; then
        log_error "hcloud CLI not found. Run: nix shell nixpkgs#hcloud"
        exit 1
    fi

    if ! command -v nixos-anywhere &>/dev/null; then
        log_error "nixos-anywhere not found. Run: nix shell nixpkgs#nixos-anywhere"
        exit 1
    fi
}

check_ssh_key() {
    log_info "Checking SSH key '$SSH_KEY_NAME' in Hetzner..."
    if ! hcloud ssh-key describe "$SSH_KEY_NAME" &>/dev/null; then
        log_warn "SSH key '$SSH_KEY_NAME' not found in Hetzner"
        log_info "Creating SSH key from local public key..."

        local pubkey_file="$HOME/.ssh/id_ed25519.pub"
        if [[ ! -f "$pubkey_file" ]]; then
            log_error "Public key not found at $pubkey_file"
            log_info "Generate one with: ssh-keygen -t ed25519"
            exit 1
        fi

        hcloud ssh-key create --name "$SSH_KEY_NAME" --public-key-from-file "$pubkey_file"
        log_success "SSH key created"
    else
        log_success "SSH key exists"
    fi
}

check_flake_config() {
    local hostname="$1"
    log_info "Checking flake configuration for '$hostname'..."

    if ! nix flake show "$FLAKE_DIR" 2>/dev/null | grep -q "nixosConfigurations.*$hostname"; then
        log_error "No NixOS configuration found for '$hostname' in flake.nix"
        log_info "Available configurations:"
        nix flake show "$FLAKE_DIR" 2>/dev/null | grep -A 100 "nixosConfigurations" | head -20
        exit 1
    fi
    log_success "Configuration exists"
}

get_server_ip() {
    local hostname="$1"
    hcloud server describe "$hostname" -o format='{{.PublicNet.IPv4.IP}}' 2>/dev/null || echo ""
}

create_server() {
    local hostname="$1"

    log_info "Creating Hetzner server '$hostname'..."
    log_info "  Type: $SERVER_TYPE"
    log_info "  Location: $LOCATION"
    log_info "  Image: $IMAGE"

    hcloud server create \
        --name "$hostname" \
        --type "$SERVER_TYPE" \
        --image "$IMAGE" \
        --location "$LOCATION" \
        --ssh-key "$SSH_KEY_NAME"

    log_success "Server created"

    # Wait for server to be ready
    log_info "Waiting for server to be running..."
    local attempts=0
    while [[ $(hcloud server describe "$hostname" -o format='{{.Status}}') != "running" ]]; do
        sleep 2
        ((attempts++))
        if [[ $attempts -gt 30 ]]; then
            log_error "Server failed to start"
            exit 1
        fi
    done
    log_success "Server is running"
}

wait_for_ssh() {
    local ip="$1"
    log_info "Waiting for SSH to be available at $ip..."

    local attempts=0
    while ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o BatchMode=yes "root@$ip" exit 2>/dev/null; do
        sleep 5
        ((attempts++))
        if [[ $attempts -gt 24 ]]; then  # 2 minutes
            log_error "SSH connection timed out"
            exit 1
        fi
        echo -n "."
    done
    echo
    log_success "SSH is available"
}

deploy_nixos() {
    local hostname="$1"
    local ip="$2"

    log_info "Deploying NixOS to $hostname ($ip)..."
    log_warn "This will WIPE the server and install NixOS"

    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Aborted"
        exit 0
    fi

    nixos-anywhere \
        --flake "$FLAKE_DIR#$hostname" \
        --target-host "root@$ip"

    log_success "NixOS deployed successfully!"
    log_info ""
    log_info "Connect with: ssh claude@$ip"
    log_info ""
}

# Parse arguments
HOSTNAME=""
CREATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --create)
            CREATE=true
            shift
            ;;
        --server-type)
            SERVER_TYPE="$2"
            shift 2
            ;;
        --location)
            LOCATION="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            ;;
        *)
            if [[ -z "$HOSTNAME" ]]; then
                HOSTNAME="$1"
            else
                log_error "Unexpected argument: $1"
                usage
            fi
            shift
            ;;
    esac
done

if [[ -z "$HOSTNAME" ]]; then
    log_error "Hostname required"
    usage
fi

# Main flow
check_prerequisites
check_flake_config "$HOSTNAME"
check_ssh_key

SERVER_IP=$(get_server_ip "$HOSTNAME")

if [[ -z "$SERVER_IP" ]]; then
    if [[ "$CREATE" == "true" ]]; then
        create_server "$HOSTNAME"
        SERVER_IP=$(get_server_ip "$HOSTNAME")
    else
        log_error "Server '$HOSTNAME' does not exist. Use --create to create it."
        exit 1
    fi
else
    log_info "Found existing server at $SERVER_IP"
fi

wait_for_ssh "$SERVER_IP"
deploy_nixos "$HOSTNAME" "$SERVER_IP"
