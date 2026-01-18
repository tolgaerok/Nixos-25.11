{
  config,
  lib,
  pkgs,
  ...
}:
{
  systemd = {
    tmpfiles.rules = [
      "D! /tmp 1777 root root 0"
      "d /home/tolga/Documents/MEGA 0775 tolga users -"
      "d /mnt/QNAP_LINUXTWEAKS 0750 tolga users -"
      "d /mnt/QNAP_PUBLIC 0750 tolga users -"
      "d /var/spool/samba 1777 root root -"
      "r! /tmp/**/*"
    ];

    user.services.megasync = {
      description = "megasync";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.megasync}/bin/megasync";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

  };
}

# Notes:
# systemctl --user status megasync --no-pager
# systemctl --user restart megasync
# systemctl --user stop megasync
