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
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    # Add pam_reattach before pam_tid.so for Touch ID in tmux
    text = ''
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so
      auth       sufficient     pam_tid.so
    '';
  };

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
      # Add any Homebrew formulae here
    ];
    casks = [
      # Add any Homebrew casks here
    ];
  };
}
