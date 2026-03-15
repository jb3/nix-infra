{ pkgs, config, ... }:
let
    ciSSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEUjgY7lb+W+YMwas7f3MgKQcsOLLh0RDhgvogt3sjd ci-runner";
in
{
    age.secrets.ci-password = {
        file = ../../secrets/ci-password.age;
    };

    users.groups = {
        www = {};
    };

    users.users.ci = {
        isSystemUser = true;
        group = "www";
        useDefaultShell = true;

        openssh.authorizedKeys.keys = [
        ''command="${pkgs.rrsync}/bin/rrsync /var/www/",restrict ${ciSSHKey}''
        ];

        hashedPasswordFile = config.age.secrets.ci-password.path;
    };
}
