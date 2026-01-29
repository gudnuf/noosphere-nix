{ pkgs, lib, config, hostname, ... }:

{
  programs.git = {
    enable = true;

    # Core settings using settings attribute
    settings = {
      user.name = "gudnuf";
      user.email = "gudnuf21@proton.me";

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;

      # Better diffs
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };

      # Merge settings
      merge = {
        conflictStyle = "zdiff3";
      };

      # Rebase settings
      rebase = {
        autoStash = true;
        autoSquash = true;
      };

      # Credential helper (platform-aware)
      credential.helper = if pkgs.stdenv.isDarwin
        then "osxkeychain"
        else "cache --timeout=3600";

      # URL shortcuts
      url = {
        "git@github.com:" = {
          insteadOf = "gh:";
        };
      };

      # Useful aliases
      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
        lg = "log --oneline --graph --decorate --all";
        amend = "commit --amend --no-edit";
        undo = "reset --soft HEAD~1";
        stash-all = "stash save --include-untracked";
      };
    } // lib.optionalAttrs (hostname == "nous") {
      # SSH signing with FIDO keys (nous only - requires physical key)
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
      commit.gpgsign = true;
      tag.gpgsign = true;
    };

    # FIDO SSH signing key (nous only)
    signing.key = lib.mkIf (hostname == "nous") "~/.ssh/id_ed25519_sk_1.pub";

    # Ignore patterns
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".direnv/"
      ".envrc"
      "result"
      "result-*"
    ];
  };

  # Delta for better diffs (root level settings)
  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "TwoDark";
    };
    enableGitIntegration = true;
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # Allowed signers file for SSH signature verification (nous only)
  # Maps email addresses to their public keys
  # To add another FIDO key, append a new line with the same email and different key
  home.file.".ssh/allowed_signers" = lib.mkIf (hostname == "nous") {
    text = ''
      gudnuf21@proton.me sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL/5XRy1Z+7QuwDoa9nn29iWfBlAAfzByuM5Gq1tpg6qAAAABHNzaDo= gudnuf21@proton.me
    '';
  };
}
