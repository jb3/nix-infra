{ ... }:
{
    services.nginx.virtualHosts."jb3.dev-tor" = {
        root = "/var/www/jb3.dev";
        listen = [{ addr = "unix:/tmp/nginx-jb3dev.sock"; }];

        locations."/" = {
            index = "index.html";
            tryFiles = "$uri $uri/ =404";
            extraConfig = ''
                error_page 404 /404.html;
            '';
        };
    };
}
