{ pkgs, config, ... }:
{
  systemd.tmpfiles.rules = [
      "d /var/www/goaccess 0775 root nginx -"
  ];

  environment.systemPackages = with pkgs; [
    goaccess
  ];

  age.secrets.logs-nginx-htpasswd = {
      file = ../secrets/nginx-htpasswd.age;
      owner = "nginx";
  };

  services.nginx.virtualHosts."logs.jb3.dev" = {
      root = "/var/www/goaccess";
      serverName = "logs.jb3.dev";
      useACMEHost = "jb3.dev-prod";
      forceSSL = true;

      basicAuthFile = config.age.secrets."logs-nginx-htpasswd".path;

      locations."/" = {
          index = "index.html";
          tryFiles = "$uri $uri/ =404";
      };
  };

  systemd.timers."goaccess-update" = {
    description = "Update goaccess stats every 5 minutes";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*:0/5";
      Persistent = true;
      Unit = "goaccess-update.service";
    };
  };

  systemd.services."goaccess-update" = {
    description = "Update goaccess stats";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.goaccess}/bin/goaccess -f /var/log/nginx/access.log -o /var/www/goaccess/index.html --log-format=COMBINED";
      User = "nginx";
    };
  };
}
