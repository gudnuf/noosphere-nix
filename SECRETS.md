# Secrets Management Guide

This document explains how secrets (API tokens, credentials, etc.) are managed in this Nix configuration.

## The Problem

You need to use sensitive data like API tokens in your environment, but you can't commit them to Git. Additionally, on macOS there's a complication: **GUI applications don't inherit shell environment variables**.

This means:
- ✅ Setting `export GITHUB_TOKEN=xyz` in `.zshrc` works for terminal apps
- ❌ But Claude Code (a GUI app) won't see that variable

## The Solution

This configuration uses a two-tier approach:

1. **`secrets.nix`** - A git-ignored file containing your actual secrets
2. **Dual environment setup** - Makes secrets available to both shell and GUI apps

## How It Works

### File Structure

```
secrets.nix.template    # Template (committed to git)
secrets.nix            # Your actual secrets (git-ignored, NEVER committed)
```

### The Flow

1. **You create `secrets.nix`** with your secrets:
   ```nix
   {
     GITHUB_PERSONAL_ACCESS_TOKEN = "ghp_your_actual_token_here";
     OPENAI_API_KEY = "sk-your-key-here";
   }
   ```

2. **Nix configuration imports it** (`home/default.nix`):
   ```nix
   let
     secretsPath = ../secrets.nix;
     secrets = if builtins.pathExists secretsPath
       then import secretsPath
       else {};
   in
   ```

   This safely imports secrets if the file exists, or uses an empty set if it doesn't.

3. **For shell sessions** - Secrets are merged into `home.sessionVariables`:
   ```nix
   home.sessionVariables = {
     EDITOR = "nvim";
     VISUAL = "nvim";
   } // secrets;  # Merges all secrets
   ```

   When you rebuild, these get exported in `~/.zshenv` and are available in your terminal.

4. **For GUI apps** - Secrets are set in macOS's launchd environment:
   ```nix
   launchd.agents = pkgs.lib.mapAttrs' (name: value:
     pkgs.lib.nameValuePair "setenv-${name}" {
       enable = true;
       config = {
         ProgramArguments = [ "${pkgs.bash}/bin/bash" "-c"
           "/bin/launchctl setenv ${name} '${value}'" ];
         RunAtLoad = true;
       };
     }
   ) secrets;
   ```

   This creates launchd agents that run `launchctl setenv` for each secret at login.

## Why Two Methods?

| Method | Purpose | When It's Set | What Can Access It |
|--------|---------|---------------|-------------------|
| `home.sessionVariables` | Shell access | When Home Manager rebuilds | Terminal, shell scripts, processes launched from terminal |
| `launchd.agents` | System-wide access | At login (via launchd) | All GUI apps, menu bar apps, apps launched via Spotlight |

**The key insight:** macOS applications launched from Finder/Spotlight/Dock don't inherit your shell environment. They get their environment from `launchd`, the system-level process manager.

## Setup Instructions

### First Time Setup

1. **Copy the template:**
   ```bash
   cd ~/.config/nix-config
   cp secrets.nix.template secrets.nix
   ```

2. **Edit `secrets.nix` with your actual secrets:**
   ```bash
   nvim secrets.nix
   ```

   Example:
   ```nix
   {
     # GitHub Personal Access Token for Claude Code MCP
     GITHUB_PERSONAL_ACCESS_TOKEN = "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";

     # OpenAI API key
     OPENAI_API_KEY = "sk-proj-your-key-here";

     # Any other secrets
     DATABASE_URL = "postgresql://user:pass@localhost/db";
   }
   ```

3. **Rebuild your configuration:**
   ```bash
   nrs  # Alias for darwin-rebuild switch
   ```

4. **For immediate access (without logout/login):**
   ```bash
   # Set in current launchd session
   launchctl setenv GITHUB_PERSONAL_ACCESS_TOKEN "your_token_here"

   # Verify it's set
   launchctl getenv GITHUB_PERSONAL_ACCESS_TOKEN
   ```

5. **Restart GUI apps** that need the secrets (like Claude Code)

### Adding New Secrets

1. Edit `secrets.nix` and add the new key-value pair
2. Run `nrs` to rebuild
3. For immediate effect without reboot, manually set in launchd:
   ```bash
   launchctl setenv NEW_SECRET_NAME "value"
   ```
4. Restart affected applications

## Verification

### Check Shell Access

```bash
# Source your environment
source ~/.zshenv

# Check if secret is available
echo $GITHUB_PERSONAL_ACCESS_TOKEN
```

### Check GUI App Access

```bash
# Check launchd environment
launchctl getenv GITHUB_PERSONAL_ACCESS_TOKEN
```

If the launchd command returns empty, GUI apps won't see the variable.

## The launchd Agent (Manual Setup)

The Nix configuration should automatically create launchd agents, but if you need to set up manually:

1. **Create the plist file** at `~/Library/LaunchAgents/com.user.setenv.plist`:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.user.setenv</string>
       <key>ProgramArguments</key>
       <array>
           <string>/bin/sh</string>
           <string>-c</string>
           <string>
           /bin/launchctl setenv GITHUB_PERSONAL_ACCESS_TOKEN "your_token_here"
           /bin/launchctl setenv ANOTHER_SECRET "another_value"
           </string>
       </array>
       <key>RunAtLoad</key>
       <true/>
   </dict>
   </plist>
   ```

2. **Load the agent:**
   ```bash
   launchctl load ~/Library/LaunchAgents/com.user.setenv.plist
   ```

3. **Reload after changes:**
   ```bash
   launchctl unload ~/Library/LaunchAgents/com.user.setenv.plist
   launchctl load ~/Library/LaunchAgents/com.user.setenv.plist
   ```

## Security Considerations

### What's Protected

- ✅ `secrets.nix` is in `.gitignore` - it will NEVER be committed
- ✅ The template file only shows the structure, not real values
- ✅ If `secrets.nix` doesn't exist, the config gracefully handles it (empty set)
- ✅ Secrets are stored in plain text on your local machine only

### What's NOT Protected

- ❌ Secrets are stored in **plain text** in `secrets.nix`
- ❌ Secrets are visible in **Nix store** paths (world-readable)
- ❌ Secrets appear in **launchd environment** (visible to all processes)
- ❌ Anyone with access to your user account can read them

### Important Notes

1. **This is NOT encryption** - It's just keeping secrets out of version control
2. **Nix store is world-readable** - Don't use this for highly sensitive secrets
3. **For production systems**, consider:
   - [agenix](https://github.com/ryantm/agenix) - Age-encrypted secrets for NixOS
   - [sops-nix](https://github.com/Mic92/sops-nix) - SOPS integration for Nix
   - macOS Keychain access via scripts
   - 1Password CLI with secret references

4. **This approach is suitable for:**
   - Development API tokens
   - GitHub Personal Access Tokens
   - Non-critical credentials
   - Tokens that can be easily rotated

## Troubleshooting

### GUI app can't see environment variables

**Symptom:** Claude Code shows "Missing environment variables: GITHUB_PERSONAL_ACCESS_TOKEN"

**Solutions:**
1. Check launchd environment: `launchctl getenv GITHUB_PERSONAL_ACCESS_TOKEN`
2. If empty, set it manually: `launchctl setenv GITHUB_PERSONAL_ACCESS_TOKEN "your_token"`
3. Restart the GUI application
4. For persistence, ensure launchd agent exists and is loaded

### Variables work in terminal but not in GUI apps

**Cause:** Shell variables (`~/.zshenv`) aren't inherited by GUI apps on macOS.

**Solution:** Ensure launchd environment is set (see above).

### After reboot, GUI apps lose access

**Cause:** launchd agent isn't running at login.

**Solution:**
1. Check if agent exists: `ls ~/Library/LaunchAgents/com.user.setenv.plist`
2. Load it: `launchctl load ~/Library/LaunchAgents/com.user.setenv.plist`
3. Verify it runs at login (RunAtLoad should be true)

### Secrets aren't being imported

**Symptom:** Variables are empty even after rebuild.

**Check:**
1. Does `secrets.nix` exist? `ls ~/.config/nix-config/secrets.nix`
2. Is the syntax correct? `nix eval --file ~/.config/nix-config/secrets.nix`
3. Is it being imported? Check `home/default.nix` for the import logic

## Real-World Example: Claude Code GitHub Plugin

The Claude Code GitHub MCP plugin needs `GITHUB_PERSONAL_ACCESS_TOKEN` to work.

**Before the fix:**
- Error: "Missing environment variables: GITHUB_PERSONAL_ACCESS_TOKEN"
- Even though it was set in `.zshenv`, Claude Code (GUI app) couldn't see it

**After the fix:**
1. Created `secrets.nix` with the token
2. Ran `nrs` to rebuild
3. Set in launchd: `launchctl setenv GITHUB_PERSONAL_ACCESS_TOKEN "ghp_..."`
4. Restarted Claude Code
5. Plugin now works - it can access GitHub API

**Why it works now:**
- Shell access: Token in `home.sessionVariables` → exported in `~/.zshenv`
- GUI access: Token set via `launchctl setenv` → available to all GUI apps

## Alternative Approaches

If this approach doesn't meet your needs:

### 1. Environment Variable in .zshenv (Shell only)
```bash
# ~/.zshenv
export GITHUB_PERSONAL_ACCESS_TOKEN="your_token"
```
**Pros:** Simple
**Cons:** Only works for terminal apps, not GUI apps

### 2. macOS Keychain + Script
Store in Keychain, retrieve in script:
```bash
security find-generic-password -s "github_token" -w
```
**Pros:** More secure
**Cons:** More complex, requires scripting

### 3. 1Password CLI
Reference secrets from 1Password:
```bash
op read "op://Private/GitHub Token/credential"
```
**Pros:** Very secure, centralized
**Cons:** Requires 1Password subscription, CLI setup

### 4. Encrypted Secrets (agenix/sops-nix)
Encrypt secrets in the repo, decrypt at runtime:
**Pros:** Can commit to git (encrypted), very secure
**Cons:** Complex setup, requires key management

## Summary

This configuration provides a **simple, practical solution** for managing development secrets in a Nix environment:

- ✅ Secrets stay out of version control
- ✅ Works for both shell and GUI applications
- ✅ Easy to add new secrets
- ✅ Gracefully handles missing secrets file
- ⚠️ Not suitable for highly sensitive production secrets
- ⚠️ Secrets are stored in plain text locally

For most development workflows (API tokens, GitHub tokens, etc.), this is sufficient and convenient.
