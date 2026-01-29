# TODO - Claude Code Cloud MVP

## Phase 1: Core Infrastructure

- [ ] Create `modules/nixos/cloud-instance.nix`
  - [ ] Define `services.cloudInstance.enable` option
  - [ ] Define `services.cloudInstance.userSshKey` option
  - [ ] Define `services.cloudInstance.instanceId` option
  - [ ] Define `services.cloudInstance.expiresAt` option
  - [ ] Inject SSH key into `users.users.claude.openssh.authorizedKeys.keys`
  - [ ] Write instance metadata to `/etc/cloud-instance/`

- [ ] Create `hosts/cloud-instance/` directory
  - [ ] Create `default.nix` (minimal host config, no hardcoded SSH keys)
  - [ ] Create `hardware-configuration.nix` (copy from hetzner)
  - [ ] Create `networking.nix` (DHCP-based)

- [ ] Modify `flake.nix`
  - [ ] Add `mkCloudInstance` helper function
  - [ ] Add `cloud-instance` to `nixosConfigurations`

- [ ] Create `CLAUDE.cloud-instance.md` (host context file)

- [ ] Test: Verify `nix build .#nixosConfigurations.cloud-instance.config.system.build.toplevel` succeeds

---

## Phase 2: Provisioning Automation

- [ ] Create `state/` directory
  - [ ] Add `.gitkeep`
  - [ ] Update `.gitignore` to exclude `state/instances.json`

- [ ] Create `scripts/cloud/lib/state.sh`
  - [ ] Implement `init_state()` function
  - [ ] Implement `add_instance()` function
  - [ ] Implement `remove_instance()` function
  - [ ] Implement `get_instance()` function
  - [ ] Implement `list_instances()` function
  - [ ] Implement `get_expired()` function

- [ ] Create `scripts/cloud/provision.sh`
  - [ ] Parse arguments (email, ssh-key, hours, server-type)
  - [ ] Validate SSH key format
  - [ ] Generate instance ID
  - [ ] Create Hetzner server via hcloud
  - [ ] Wait for SSH availability
  - [ ] Deploy NixOS via nixos-anywhere with user's SSH key
  - [ ] Update state file
  - [ ] Output connection info

- [ ] Create `scripts/cloud/deprovision.sh`
  - [ ] Parse instance ID argument
  - [ ] Look up instance in state
  - [ ] Delete Hetzner server
  - [ ] Remove from state file

- [ ] Test: Full provision/deprovision cycle works

---

## Phase 3: Lifecycle Management

- [ ] Create `scripts/cloud/check-expired.sh`
  - [ ] Query state for expired instances
  - [ ] Call deprovision.sh for each expired instance

- [ ] Create `scripts/cloud/extend.sh`
  - [ ] Parse instance ID and hours arguments
  - [ ] Update expiresAt in state file

- [ ] Create `scripts/cloud/status.sh`
  - [ ] Show instance details from state
  - [ ] Show remaining time until expiration

- [ ] Set up cron job for check-expired.sh (document in README)

- [ ] Test: Instance expires and is cleaned up automatically

---

## Phase 4: CLI Interface

- [ ] Create `scripts/cloud/ccc` CLI wrapper
  - [ ] Implement `provision` subcommand
  - [ ] Implement `deprovision` subcommand
  - [ ] Implement `status` subcommand
  - [ ] Implement `list` subcommand
  - [ ] Implement `extend` subcommand
  - [ ] Implement `types` subcommand
  - [ ] Add help text for all commands

- [ ] Test: All CLI commands work correctly

---

## Future (Post-MVP)

- [ ] Web interface / API layer
- [ ] Stripe integration for automated billing
- [ ] Persistent storage between sessions
- [ ] Custom package requests from users
- [ ] Team access (multiple SSH keys per instance)
- [ ] Region selection (fsn1, nbg1, hel1, ash)
- [ ] Instance snapshots / save-restore
- [ ] Usage analytics / billing reports
