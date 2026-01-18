{ config, lib, pkgs, ... }:

{
  systemd = {
    tmpfiles.rules = [
      "D! /tmp 1777 root root 0"
      "d /home/tolga/Documents/MEGA 0775 tolga users -"
      "d /var/spool/samba 1777 root root -"
      "r! /tmp/**/*"
    ];

    services.NetworkManager-wait-online.enable = false;

    settings.Manager = {
      DefaultLimitNOFILE = "1048576";
      DefaultStandardError = "null";
      DefaultStandardOutput = "null";
      DefaultTimeoutStopSec = "1s";
      ShowStatus = "no";
    };

    coredump.enable = true;

    services.avahi-daemon-setup = {
      description = "Create Avahi Runtime Directory";
      before = [ "avahi-daemon.service" ];
      requiredBy = [ "avahi-daemon.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/mkdir -p /run/avahi-daemon";
        ExecStartPost =
          "${pkgs.coreutils}/bin/chown avahi:avahi /run/avahi-daemon";
      };
    };

    services.avahi-daemon.preStart = lib.mkForce ''
      rm -f /run/avahi-daemon/pid || true
    '';

    user.services.easyeffects = {
      description = "easyeffects daemon";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.flatpak}/bin/flatpak run --branch=stable --arch=x86_64 com.github.wwmm.easyeffects --gapplication-service";
        Restart = "on-failure";
      };
    };

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
