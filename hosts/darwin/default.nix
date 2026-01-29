{ pkgs, hostname, username, ... }:

{
  # Hostname
  networking.hostName = hostname;

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Enable Touch ID for sudo with pam_reattach for tmux support
  # Note: Using Homebrew's pam-reattach because it links against system PAM (required for Sequoia)
  # The Nix version links against OpenPAM from Nix store which doesn't work properly
  security.pam.services.sudo_local.text = ''
    auth       optional       /opt/homebrew/lib/pam/pam_reattach.so
    auth       sufficient     pam_tid.so
  '';

  # Disable nix-darwin's Nix management (using Determinate Nix)
  nix.enable = false;

  # System settings
  system = {
    # Used for backwards compatibility
    stateVersion = 5;

    # Set primary user for system defaults
    primaryUser = username;

    # macOS system defaults
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.trackpad.enableSecondaryClick" = true;
      };

      dock = {
        autohide = true;
        show-recents = false;
        mru-spaces = false;
        minimize-to-application = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # Homebrew configuration (managed declaratively)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    brews = [
      "pam-reattach"  # For Touch ID in tmux (must link against system PAM)
    ];
    casks = [
      "iterm2"
      "utm"  # Virtual machine host for testing NixOS configs
    ];
  };
}
