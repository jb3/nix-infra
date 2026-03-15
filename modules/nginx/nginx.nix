{ ... }:
{
    imports = [
        ./sites/blog.nix
    ];

    services.nginx = {
        enable = true;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    users.users.nginx.extraGroups = [ "acme" ];
}
