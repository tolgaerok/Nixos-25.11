{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot = {
    # TPM causes hangs - disable it
    blacklistedKernelModules = [
      "tpm"
      "tpm_tis"
      "tpm_crb"
    ];

    # Silent boot
    consoleLogLevel = 0;

    # Tmpfs
    tmp.cleanOnBoot = false;
    tmp.tmpfsSize = "25%";
    tmp.useTmpfs = true;

    # Kernel
    kernelPackages = pkgs.linuxPackages_xanmod;

    # Plymouth for boot splash
    plymouth = {
      enable = true;
      theme = "breeze"; # or "spinner"
    };

    # Bootloader
    loader = {
      systemd-boot = {
        consoleMode = "max";
        editor = true;
        enable = true;
        memtest86.enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    # Plymouth initrd setup
    initrd = {
      systemd.enable = true;
      verbose = false;
      systemd.services.plymouth-start = {
        wantedBy = [ "sysinit.target" ];
        before = [ "systemd-ask-password-console.service" ];
        conflicts = [ "emergency.target" ];
      };
    };
  };

  # Fix avahi runtime directory issue, a head fuck
  systemd.services.avahi-daemon-setup = {
    description = "Create Avahi Runtime Directory";
    before = [ "avahi-daemon.service" ];
    requiredBy = [ "avahi-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/mkdir -p /run/avahi-daemon";
      ExecStartPost = "${pkgs.coreutils}/bin/chown avahi:avahi /run/avahi-daemon";
    };
  };

  systemd.services.avahi-daemon.preStart = lib.mkForce ''
    rm -f /run/avahi-daemon/pid || true
  '';

  # Disable TPM
  security.tpm2.enable = false;

  # Suppress systemd status messages
  systemd.settings.Manager = {
    ShowStatus = "no";
    DefaultStandardOutput = "null";
    DefaultStandardError = "null";
  };

  # Block slow serial/TPM devices on my machine
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", KERNEL=="ttyS[0-3]", ENV{SYSTEMD_READY}="0"
    SUBSYSTEM=="tpm", ENV{SYSTEMD_READY}="0"
  '';
}
