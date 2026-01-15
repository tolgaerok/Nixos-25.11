{ config, lib, pkgs, ... }: {
  services = {
    # udev rules
    udev = {
      enable = true;
      extraRules = ''
        # Sound devices to audio group
        # KERNEL=="rtc0", GROUP="audio"
        # KERNEL=="hpet", GROUP="audio"

        # SSD optimization - aggressive desktop tuning (8GB read-ahead, BFQ scheduler)
        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq", ATTR{queue/read_ahead_kb}="2048", ATTR{queue/iosched/low_latency}="1", ATTR{queue/add_random}="0", ATTR{queue/nr_requests}="256"

        # NVMe optimization - no scheduler needed (none), aggressive read-ahead
        ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none", ATTR{queue/read_ahead_kb}="8192", ATTR{queue/add_random}="0", ATTR{queue/nr_requests}="256"

        # eMMC/SD cards - no scheduler
        ACTION=="add|change", KERNEL=="mmcblk[0-9]", ATTR{queue/scheduler}="none"

        # Power management (desktop aggressive = keep devices active)
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
        ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="on"
      '';
    };

    # System services
    devmon.enable = true;
    envfs.enable = true;
    fwupd.enable = true;
    geoclue2.enable = true;
    gvfs.enable = true;
    resolved.enable = true;
    rpcbind.enable = true;
    udisks2.enable = true;

    # GNOME keyring (secret service)
    gnome.gnome-keyring.enable = true;
    gnome.gcr-ssh-agent.enable = false;

    # SMART monitoring
    smartd = {
      enable = true;
      autodetect = true;
    };

    # SMART metrics exporter
    prometheus.exporters.smartctl = {
      enable = true;
      maxInterval = "20s";
    };

    # SSH
    openssh.enable = true;

    # SSD maintenance
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # X11
    xserver = {
      enable = true;
      xkb = {
        layout = "au";
        variant = "";
      };
    };

    # Display and desktop
    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
      # defaultSession = "plasmax11";
    };
    desktopManager.plasma6.enable = true;

  };

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
}
