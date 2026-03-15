{ ... }:
{
    systemd.tmpfiles.rules = [
        "d /var/www/files 0755 root root -"
    ];

    services.nginx.virtualHosts."files.jb3.dev" = {
        root = "/var/www/files";
        serverName = "files.jb3.dev";
        useACMEHost = "jb3.dev-prod";
        forceSSL = true;
    };
}
