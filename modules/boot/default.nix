{ config, pkgs, lib, ... }: {
  # Bootloader
  boot = {
    initrd = {
      systemd.enable = true;
      verbose = false;
    };

    # Silence ACPI "errors" at boot
    consoleLogLevel = 3;

    # Clean tmpfs on boot
    tmp.cleanOnBoot = true;
    tmp.tmpfsSize = "25%";
    tmp.useTmpfs = true;

    # Kernel
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_xanmod;

    # Plymouth
    plymouth = {
      enable = true;
      theme = "breeze";
    };

    # Bootloader
    loader = {
      systemd-boot = {
        consoleMode = "max";
        editor = true;
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
