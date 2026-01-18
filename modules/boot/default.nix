{ config, pkgs, lib, ... }: {

  # Disable TPM
  security.tpm2.enable = false;

  boot = {
    # TPM causes hangs - disable it
    blacklistedKernelModules = [ "tpm" "tpm_tis" "tpm_crb" ];

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
        # configurationLimit = 3;
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
}
