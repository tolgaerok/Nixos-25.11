{ config, lib, pkgs, ... }: {
  systemd = {
    tmpfiles.rules = [
      "D! /tmp 1777 root root 0"
      "d /home/tolga/Documents/MEGA 0775 tolga samba -"
      "d /mnt/QNAP_LINUXTWEAKS 0750 tolga tolga -"
      "d /mnt/QNAP_PUBLIC 0750 tolga tolga -"
      "d /var/spool/samba 1777 root root -"
      "r! /tmp/**/*"
    ];

  };
}
