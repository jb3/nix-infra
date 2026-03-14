{ config, ... }:
{
  age.secrets.user-password = {
    file = ../secrets/user-password.age;
  };

  users.mutableUsers = false;

  users.users.joe = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyNdEOw7tfOHWCM0w2A7UzspnYYpNiF+nak51dcx3d7 joe@ivo"
    ];

    hashedPasswordFile = config.age.secrets.user-password.path;
  };

  security.sudo.wheelNeedsPassword = false;
}
