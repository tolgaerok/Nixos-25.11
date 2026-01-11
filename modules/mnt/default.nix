{ config, lib, pkgs, ... }: {
  # QNAP network mount

  # PUBLIC
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

  # LINUXTWEAKS
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
}
