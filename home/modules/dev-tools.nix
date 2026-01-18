{ pkgs, ... }:

{
  # Development tools
  home.packages = with pkgs; [
    # Search and navigation
    ripgrep      # Fast grep
    fd           # Fast find
    tree         # Directory tree
    jq           # JSON processor
    yq           # YAML processor

    # File viewers
    less         # Pager
    file         # File type detection
    glow         # Markdown renderer

    # Networking
    curl
    wget
    httpie       # HTTP client

    # Process management
    htop         # Process viewer
    bottom       # System monitor

    # Compression
    zip
    unzip
    p7zip

    # Nix tools
    nixfmt      # Nix formatter
    nil         # Nix LSP
    nix-tree    # Visualize nix dependencies

    # Development
    gnumake
    cmake

    # Git tools
    lazygit      # Git TUI

    # AI tools
    claude-code  # Claude Code CLI
  ];

  # direnv - per-directory environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # tmux - terminal multiplexer
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
    historyLimit = 50000;
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = ''
      # Mouse support
      set -g mouse on

      # Better splitting
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Status bar styling
      set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
      set -g status-left-length 40
      set -g status-right-length 60
    '';
  };

  # SSH config management
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };
    };
  };
}
