{ config, ... }:
{
    age.secrets = {
        torHsSecretKey = {
            file = ../secrets/hs_ed25519_secret_key.age;
            path = "/var/lib/tor/onion/jb3dev/hs_ed25519_secret_key";
            owner = "tor";
            mode = "0600";
        };
    };

    services.tor = {
        enable = true;

        client.enable = true;

        relay.onionServices = {
            jb3dev = {
                map = [
                    {
                        port = 80;
                        target.unix = "/tmp/nginx-jb3dev.sock";
                    }
                ];

                # Hostname and public key are inferred from secret key.
                secretKey = config.age.secrets.torHsSecretKey.path;

                version = 3;
            };
        };
    };

    systemd.services.tor = {
        unitConfig = {
            JoinsNamespaceOf = [ "nginx.service" ];
            After = [ "nginx.service" ];
            Requires = [ "nginx.service" ];
        };
        serviceConfig.PrivateTmp = true;
    };
}
