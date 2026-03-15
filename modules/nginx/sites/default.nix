{ ... }:
{
    services.nginx.virtualHosts."default-server" = {
        default = true;
        useACMEHost = "jb3.dev-prod";
        forceSSL = true;

        locations."/" = {
            extraConfig = ''
                default_type text/plain;
                add_header Content-Type text/plain;
                return 404 "Not found, apologies.";
            '';
        };
    };
}
