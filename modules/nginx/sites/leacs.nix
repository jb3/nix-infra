{ config, ... }:
{
    systemd.tmpfiles.rules = [
        "d /var/www/leacs 0755 root root -"
    ];

    age.secrets.nginx-htpasswd = {
        file = ../../../secrets/nginx-htpasswd.age;
        owner = "nginx";
    };

    services.nginx.virtualHosts."leacs.jb3.dev" = {
        root = "/var/www/leacs";
        serverName = "leacs.jb3.dev";
        useACMEHost = "jb3.dev-prod";
        forceSSL = true;

        basicAuthFile = config.age.secrets."nginx-htpasswd".path;

        locations."/" = {
            index = "index.html";
            tryFiles = "$uri $uri/ =404";
        };
    };
}
