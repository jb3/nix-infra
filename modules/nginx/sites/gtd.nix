{ config, ... }:
{
    systemd.tmpfiles.rules = [
        "d /var/www/gtd 0755 root root -"
    ];

    age.secrets.nginx-htpasswd = {
        file = ../../../secrets/nginx-htpasswd.age;
        owner = "nginx";
    };

    services.nginx.virtualHosts."gtd.jb3.dev" = {
        root = "/var/www/gtd";
        serverName = "gtd.jb3.dev";
        useACMEHost = "jb3.dev-prod";
        forceSSL = true;

        locations."/" = {
            index = "index.html";
            tryFiles = "$uri $uri/ =404";
        };
    };
}
