{ ... }:
{
    services.nginx = {
        enable = true;

        virtualHosts."jb3.dev-prod" = {
            root = "/var/www/jb3.dev";
            serverName = "jb3.dev www.jb3.dev";
            useACMEHost = "jb3.dev-prod";
            forceSSL = true;

            locations."/" = {
                extraConfig = ''
                    add_header Content-Type text/plain;
                    return 200 "Hello, world!\n";
                '';
            };
        };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    users.users.nginx.extraGroups = [ "acme" ];
}
