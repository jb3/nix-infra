{ self, config, ... }:
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
          file = builtins.toFile "jb3.dev.zone" (builtins.replaceStrings
            [ "SERIAL" ]
            [ (toString self.lastModified) ]
            (builtins.readFile ./zones/jb3.dev.zone));
          acl = "acl-rfc2136-update";
        }
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
