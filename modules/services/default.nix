{ config, lib, pkgs, ... }: {
  services = {

    # udev rules
    udev = {
      enable = true;

    };

    # System services
    # resolved.enable = true;
    devmon.enable = true;
    envfs.enable = true;
    fwupd.enable = true;
    # geoclue2.enable = true;
    gvfs.enable = true;
    # nfs.server.enable = true;
    # rpcbind.enable = true;
    udisks2.enable = true;

    # Thumbnail generation
    tumbler.enable = true;

    # SMART monitoring
    smartd = {
      enable = true;
      autodetect = true;
    };

    # SSH
    openssh.enable = true;

    # SSD maintenance
    fstrim = {
      enable = true;
      interval = "weekly";
    };
  };
}
