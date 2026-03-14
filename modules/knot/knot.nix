{ self, ... }:
{
  services.knot = {
    enable = true;
    settings = {
      server = {
        listen = [
          "0.0.0.0@53"
          "::@53"
        ];
      };

      zone = [
        {
          domain = "jb3.dev";
          file = builtins.toFile "jb3.dev.zone" (builtins.replaceStrings
            [ "SERIAL" ]
            [ (toString self.lastModified) ]
            (builtins.readFile ./zones/jb3.dev.zone));
        }
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
