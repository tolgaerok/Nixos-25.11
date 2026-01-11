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
    tmp.useTmpfs = true;
    tmp.tmpfsSize = "30%";

    # Kernel
    kernelPackages = pkgs.linuxPackages_latest;

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
