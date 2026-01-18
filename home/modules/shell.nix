{ pkgs, hostname, ... }:

let
  rebuildCmd = if pkgs.stdenv.isDarwin then "darwin-rebuild" else "nixos-rebuild";
in
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
      nrs = "sudo ${rebuildCmd} switch --flake ~/.config/nix-config#${hostname}";
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

  # Starship prompt with theme colors
  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status$nix_shell$nodejs$python$rust$language$cmd_duration$character";
      add_newline = true;

      # Character module - prompt indicator
      character = {
        success_symbol = "[➜](bold #82aaff)";
        error_symbol = "[➜](bold #ff757f)";
      };

      # Directory module with deep blue theme
      directory = {
        style = "bold #89ddff";
        truncation_length = 3;
        truncation_symbol = "…/";
        home_symbol = "~";
        format = "[$read_only$path]($style) ";
        read_only = "🔒 ";
        read_only_style = "#ff757f";
      };

      # Git branch module
      git_branch = {
        symbol = " ";
        style = "#c3e88d";
        format = "on [$symbol$branch]($style) ";
      };

      # Git status module with semantic colors
      git_status = {
        style = "bold #ffcb6b";
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        ahead = "[⇡\${count}](#82aaff)";
        behind = "[⇣\${count}](#ff757f)";
        diverged = "[⇕⇡\${ahead_count}⇣\${behind_count}](#ffcb6b)";
        untracked = "[?](#c3e88d)";
        stashed = "[📦](#82aaff)";
        modified = "[!](#ffcb6b)";
        staged = "[+](#c3e88d)";
        renamed = "[»](#82aaff)";
        deleted = "[✘](#ff757f)";
      };

      # Nix shell indicator
      nix_shell = {
        symbol = "";
        style = "#82aaff";
        format = "via [$symbol($state)]($style) ";
      };

      # Command duration - show if longer than 2s
      cmd_duration = {
        min_time = 2000;
        style = "#ffcb6b";
        format = "took [$duration]($style) ";
      };

      # Language indicators
      nodejs = {
        symbol = " ";
        style = "#c3e88d";
        format = "via [$symbol($version)]($style) ";
      };

      python = {
        symbol = "🐍 ";
        style = "#ffcb6b";
        format = "via [$symbol($version)]($style) ";
      };

      rust = {
        symbol = "🦀 ";
        style = "#ff757f";
        format = "via [$symbol($version)]($style) ";
      };

      # Disable unused modules
      time.disabled = true;
      username.disabled = true;
      hostname.disabled = true;
    };
  };

  # fzf - fuzzy finder with deep blue color theme
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--color=bg:#1a1d2e,bg+:#1e2030"
      "--color=fg:#cdd6f4,fg+:#89ddff"
      "--color=hl:#82aaff,hl+:#82aaff"
      "--color=border:#3b3f5f"
      "--color=pointer:#89ddff"
      "--color=marker:#c3e88d"
      "--color=spinner:#ffcb6b"
      "--color=header:#ff757f"
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

  # bat - better cat with monokai theme for consistency
  programs.bat = {
    enable = true;
    config = {
      theme = "Monokai Extended";
      style = "numbers,changes,header";
    };
  };
}
