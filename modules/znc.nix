{ pkgs, ... }:
let
    zncWebPort = 5000;
    zncIRCPort = 6697;
in
{
    services.saslauthd.enable = true;
    environment.etc = {
        "pam.d/znc" = {
            source = pkgs.writeText "znc.pam" ''
            # Account management.
            account required pam_unix.so

            # Authentication management.
            auth sufficient pam_unix.so likeauth try_first_pass
            auth required pam_deny.so

            # Password management.
            password sufficient pam_unix.so nullok sha512

            # Session management.
            session required pam_env.so conffile=/etc/pam/environment readenv=0
            session required pam_unix.so
            '';
        };
    };

    services.znc = {
        enable = true;
        mutable = true;
        openFirewall = true;
        useLegacyConfig = false;

        config = {
            LoadModule = [ "adminlog" "cyrusauth saslauthd" ];
            TrustedProxy = [
                "127.0.0.1"
                "::1"
            ];
            Listener.l = {
                Port = zncWebPort;
                AllowIRC = false;
                AllowWeb = true;
                SSL = false;
            };
            Listener.irc = {
                Port = zncIRCPort;
                AllowIRC = true;
                AllowWeb = false;
                SSL = false;
            };
            User."joe" = {
                Admin = true;
                # Fake MD5 hash of empty password, to disable password login without breaking SASL.
                Pass = "md5#::#::#";
                LoadModule = [ "controlpanel" ];
            };
        };
    };

    users.users.znc.extraGroups = [ "acme" ];

    systemd.services.znc.serviceConfig.RestrictAddressFamilies = [ "AF_UNIX" ];

    services.nginx.virtualHosts."znc.jb3.dev" = {
        serverName = "znc.jb3.dev";
        useACMEHost = "jb3.dev-prod";
        forceSSL = true;

        locations."/" = {
            proxyPass = "http://localhost:${builtins.toString zncWebPort}";
            recommendedProxySettings = true;
        };
    };
}
