{ pkgs, config, ... }:

let
  sans = [
    "jb3.dev"
    "*.jb3.dev"
    "*.blog-staging.jb3.dev"
  ];
  certIdentifier = "jb3.dev-prod";
  certEmail = "joe@jb3.dev";

  rfc2136_nameserver = "127.0.0.1";
  rfc2136_tsig_algorithm = "hmac-sha256";
  rfc2136_tsig_key_name = "acme-updater";
in
{
    age.secrets."acme-tsig-key" = {
      file  = ../secrets/acme-tsig-key.age;
      owner = "root";
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = certEmail;

      certs."${certIdentifier}" = {
        domain = builtins.head sans;
        extraDomainNames = builtins.tail sans;
        server = "https://acme-v02.api.letsencrypt.org/directory";

        dnsProvider = "rfc2136";
        environmentFile = "${pkgs.writeText "acme-env" ''
          RFC2136_NAMESERVER="${rfc2136_nameserver}"
          RFC2136_TSIG_ALGORITHM="${rfc2136_tsig_algorithm}"
          RFC2136_TSIG_KEY="${rfc2136_tsig_key_name}"
        ''}";
        credentialFiles = {
          "RFC2136_TSIG_SECRET_FILE" = config.age.secrets."acme-tsig-key".path;
        };
      };
    };
}
