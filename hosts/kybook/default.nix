{ pkgs, username, ... }:

{
  imports = [
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/system.nix
  ];
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    wget
  ];

  programs.fish.enable = true;

  networking = {
    hostName = "kybook";
    computerName = "kybook";
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  system.stateVersion = 5;
  system.primaryUser = username;
}
