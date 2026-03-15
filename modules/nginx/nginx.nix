{ ... }:
{
    imports = [
        # Sites
        ./sites/default.nix
        ./sites/blog.nix
        ./sites/blog-staging.nix
        ./sites/files.nix

        # Additional configuration
        ./ci.nix
    ];

    services.nginx = {
        enable = true;

        appendHttpConfig = ''
            if_modified_since before;
        '';

        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedBrotliSettings = true;
        experimentalZstdSettings = true;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    users.users.nginx.extraGroups = [ "acme" ];
}
