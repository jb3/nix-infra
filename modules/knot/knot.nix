{ self, config, ... }:

let
  zoneText = builtins.readFile ./zones/jb3.dev.zone;

  zoneSerial = builtins.replaceStrings
    [ "a"  "b"  "c"  "d"  "e"  "f" ]
    [ "1"  "2"  "3"  "4"  "5"  "6" ]
    (builtins.substring 0 9
      (builtins.hashString "sha256" zoneText));
in
{
  age.secrets."knot-tsig-key" = {
    file  = ../../secrets/knot-tsig-key.age;
    owner = "knot";
    group = "knot";
    mode  = "0400";
  };

  services.knot = {
    enable = true;
    checkConfig = false;

    keyFiles = [ config.age.secrets."knot-tsig-key".path ];

    settings = {
      server = {
        listen = [ "0.0.0.0@53" "::@53" ];
      };

      acl = [
        {
          id     = "acl-rfc2136-update";
          key    = "acme-updater";
          action = "update";
        }
      ];

      zone = [
        {
          domain = "jb3.dev";
          file   = builtins.toFile "jb3.dev.zone" (
            builtins.replaceStrings [ "SERIAL" ] [ zoneSerial ] zoneText
          );
          acl = "acl-rfc2136-update";
          zonefile-sync = -1;
        }
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
