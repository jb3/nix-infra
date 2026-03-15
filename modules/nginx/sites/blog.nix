{ ... }:
{
    systemd.tmpfiles.rules = [
        "d /var/www/jb3.dev 0775 root www -"
        "Z /var/www/jb3.dev 0775 root www -"
    ];

    services.nginx.virtualHosts."jb3.dev" = {
        root = "/var/www/jb3.dev";
        serverName = "jb3.dev www.jb3.dev";
        useACMEHost = "jb3.dev-prod";
        forceSSL = true;

        locations."/" = {
            index = "index.html";
            tryFiles = "$uri $uri/ /404.html";
        };
    };
}
