{ pkgs, username, ... }:

{
  imports = [
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/system.nix
  ];
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;

  # curl and wget come from Homebrew; git comes from home-manager.
  environment.systemPackages = with pkgs; [
    vim
  ];

  programs.zsh.enable = true;

  networking = {
    hostName = "kybook";
    computerName = "kybook";
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    # Admin users are not managed through users.knownUsers; keep the desired
    # login shell documented here and switch it with chsh during setup.
    shell = "/bin/zsh";
  };

  system.stateVersion = 5;
  system.primaryUser = username;
}
