{ ... }:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";

  networking = {
    hostName = "odin";
    firewall.enable = true;
  };
}
