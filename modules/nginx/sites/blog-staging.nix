{ ... }:
{
    systemd.tmpfiles.rules = [
        "d /var/www/jb3.dev-staging 0775 root www -"
        "Z /var/www/jb3.dev-staging 0775 root www -"
    ];

    services.nginx.virtualHosts."jb3.dev-staging" = {
        root = "/var/www/jb3.dev-staging/$subdomain";
        serverName = "~^(?<subdomain>.+)\.blog-staging\.jb3\.dev";
        useACMEHost = "jb3.dev-prod";
        forceSSL = true;

        locations."/" = {
            index = "index.html";
            tryFiles = "$uri $uri/ =404";
            extraConfig = ''
                add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
                error_page 404 /404.html;
            '';
        };
    };
}
