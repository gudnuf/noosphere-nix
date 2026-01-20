{ pkgs, lib, ... }:

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
    mosh         # Mobile shell (SSH alternative)

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
    devenv      # Developer environments

    # Development
    gnumake
    cmake

    # Git tools
    lazygit      # Git TUI

    # AI tools
    claude-code  # Claude Code CLI

    # Cloud deployment
    hcloud       # Hetzner Cloud CLI
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # Hardware security (Darwin only)
    gnupg        # GPG for signing
    trezor-agent # Trezor GPG/SSH agent
  ];

  # direnv - per-directory environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };

  # tmux - terminal multiplexer with deep blue theme
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
    historyLimit = 50000;
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = ''
      # ============================================================================
      # THEMING - Deep Blue Color Scheme
      # ============================================================================

      # Deep blue background tones
      set -g @bg_dark "#1a1d2e"
      set -g @bg_main "#1e2030"
      set -g @bg_light "#3b3f5f"

      # Accent colors
      set -g @blue_bright "#82aaff"
      set -g @cyan "#89ddff"
      set -g @green "#c3e88d"
      set -g @yellow "#ffcb6b"
      set -g @red "#ff757f"
      set -g @text_fg "#cdd6f4"
      set -g @text_muted "#6b7086"

      # ============================================================================
      # PANE STYLING
      # ============================================================================

      # Active pane border - bright cyan
      set -g pane-active-border-style "fg=#{@cyan},bg=#{@bg_main}"
      # Inactive pane border - muted color
      set -g pane-border-style "fg=#{@bg_light},bg=#{@bg_main}"

      # ============================================================================
      # STATUS BAR STYLING
      # ============================================================================

      # Main status bar
      set -g status-style "bg=#{@bg_main},fg=#{@text_fg}"
      set -g status-left-length 40
      set -g status-right-length 60

      # Status bar left - session name and window info
      set -g status-left "#[bg=#{@blue_bright},fg=#{@bg_dark},bold] #S #[bg=#{@bg_main},fg=#{@text_fg}] "

      # Status bar right - time, date, and vim mode
      set -g status-right "#[bg=#{@bg_light},fg=#{@cyan}] #{pane_mode} #[bg=#{@bg_main}] %H:%M #[bg=#{@yellow},fg=#{@bg_dark}] %a %d "

      # Window status styling
      set -g window-status-format "#[bg=#{@bg_main},fg=#{@text_muted}] #I #W "
      set -g window-status-current-format "#[bg=#{@green},fg=#{@bg_dark},bold] #I #W #[bg=#{@bg_main},fg=#{@text_fg}] "
      set -g window-status-separator ""

      # Message styling
      set -g message-style "bg=#{@yellow},fg=#{@bg_dark},bold"
      set -g message-command-style "bg=#{@bg_light},fg=#{@cyan}"

      # Command line styling
      set -g mode-style "bg=#{@cyan},fg=#{@bg_dark}"

      # ============================================================================
      # KEYBINDINGS & FUNCTIONALITY
      # ============================================================================

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

      # Resize panes with vim keys
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
    '';
  };

  # SSH config management (platform-aware)
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    } // (if pkgs.stdenv.isDarwin then {
      identityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
    } else {});
  };
}
