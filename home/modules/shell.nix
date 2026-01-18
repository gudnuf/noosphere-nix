{ pkgs, ... }:

{
  # Zsh configuration
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Modern replacements
      ls = "eza";
      ll = "eza -la";
      la = "eza -a";
      lt = "eza --tree";
      cat = "bat";

      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";

      # Nix shortcuts
      nrs = "sudo darwin-rebuild switch --flake ~/.config/nix-config#nous";
      nfu = "nix flake update ~/.config/nix-config";
      nfc = "nix flake check ~/.config/nix-config";

      # Safety
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
    };

    initContent = ''
      # Additional zsh configuration

      # Better history search with up/down arrows
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward

      # Edit command line in editor
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^x^e' edit-command-line

      # Case insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Initialize zoxide
      eval "$(zoxide init zsh)"
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };

      directory = {
        truncation_length = 3;
        truncation_symbol = ".../";
      };

      git_branch = {
        symbol = " ";
      };

      git_status = {
        ahead = "[+\${count}](green)";
        behind = "[-\${count}](red)";
        diverged = "[+\${ahead_count}](green)[-\${behind_count}](red)";
      };

      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state( \\($name\\))]($style) ";
      };

      # Minimal right prompt
      time.disabled = true;
    };
  };

  # fzf - fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  # zoxide - smarter cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # eza - modern ls replacement
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  # bat - better cat
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };
}
