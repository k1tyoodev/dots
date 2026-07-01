{ pkgs, ... }:

{
  # macOS system preferences
  system.defaults = {
    # dock
    dock = {
      autohide = true;
      orientation = "bottom";
      tilesize = 48;
      show-recents = false;
      mru-spaces = false;
      # disable hot corners
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
    };

    # finder
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "Nlsv";
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
    };

    # global
    NSGlobalDomain = {
      # keyboard

      # mouse/trackpad
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.trackpad.scaling" = 2.5;

      # appearance
      AppleInterfaceStyle = "Dark";
      AppleShowScrollBars = "WhenScrolling";

      # window management
      NSWindowShouldDragOnGesture = true;

      # misc
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
    };

    # login window
    loginwindow = {
      GuestEnabled = false;
      DisableConsoleAccess = true;
    };

    # spaces
    spaces.spans-displays = false;

    # trackpad
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    # screenshots
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    # menu bar
    menuExtraClock = {
      Show24Hour = false;
      ShowAMPM = true;
      ShowDate = 1;
      ShowDayOfWeek = true;
    };

    # custom user preferences
    CustomUserPreferences = {
      # disable press-and-hold for keys in favor of key repeat
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
      };
    };
  };

  # security - touch id for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
