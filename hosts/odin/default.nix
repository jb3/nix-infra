{ ... }:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "odin";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}
