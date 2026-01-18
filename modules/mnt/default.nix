{ config, lib, pkgs, ... }: {
  # qnap network mounts - both cifs and nfs  
  systemd = {
    tmpfiles.rules = [
      # nfs
      "d /mnt/nfs-techs 0775 tolga users -"
      "d /mnt/nfs-Relationships 0775 tolga users -"
      "d /mnt/nfs-linuxtweaks 0775 tolga users -"
      "d /mnt/nfs-public 0775 tolga users -"
      # cifs
      "d /mnt/QNAP_LINUXTWEAKS 0750 tolga users -"
      "d /mnt/QNAP_PUBLIC 0750 tolga users -"
    ];
  };

  # public (cifs/smb)
  fileSystems."/mnt/QNAP_PUBLIC" = {
    device = "//192.168.0.17/Public";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/modules/samba/smb-secrets"
      "uid=1000"
      "gid=100"
      "file_mode=0640"
      "dir_mode=0750"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
    ];
  };

  # linuxtweaks (cifs/smb)
  fileSystems."/mnt/QNAP_LINUXTWEAKS" = {
    device = "//192.168.0.17/LINUXTWEAKS";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/modules/samba/smb-secrets"
      "uid=1000"
      "gid=100"
      "file_mode=0640"
      "dir_mode=0750"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
    ];
  };

  # public (nfs)
  fileSystems."/mnt/nfs-public" = {
    device = "192.168.0.17:/Public";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "nofail"
      "vers=3"
      "rw"
      "soft"
      "timeo=30"
    ];
  };

  # linuxtweaks (nfs)
  fileSystems."/mnt/nfs-linuxtweaks" = {
    device = "192.168.0.17:/LINUXTWEAKS";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "nofail"
      "vers=3"
      "rw"
      "soft"
      "timeo=30"
    ];
  };

  # techs (nfs)
  fileSystems."/mnt/nfs-techs" = {
    device = "192.168.0.17:/techs";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "nofail"
      "vers=3"
      "rw"
      "soft"
      "timeo=30"
    ];
  };

  # relationships (nfs)
  fileSystems."/mnt/nfs-Relationships" = {
    device = "192.168.0.17:/Public/RELATIONSHIPS";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "nofail"
      "vers=3"
      "rw"
      "soft"
      "timeo=30"
    ];
  };
}
# Notes:
# rebuild with nfs automount fix:
# sudo systemctl stop 'mnt-nfs\x2d*.automount' 2>/dev/null || true && sudo nixos-rebuild switch
# 
# setup nfs permissions on qnap for Public and LINUXTWEAKS first:
# ssh admin@192.168.0.17
# chown -R tolga:everyone /share/Public /share/LINUXTWEAKS
# chmod -R 777 /share/Public /share/LINUXTWEAKS
