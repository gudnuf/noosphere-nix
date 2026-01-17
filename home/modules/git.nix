{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    # Core settings using settings attribute
    settings = {
      user.name = "claude";
      user.email = "claude@example.com";

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

      # Credential helper (macOS keychain)
      credential.helper = "osxkeychain";

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
    };

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
}
