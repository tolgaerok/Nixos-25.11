{ config, pkgs, lib, ... }:

with lib; {
  options = {
    numlock-boot.enable = lib.mkEnableOption "Boot with NumLock on";
  };

  config = {
    # ── NumLock on boot ─────────────────────────────────────────────
    services.xserver.displayManager.setupCommands =
      mkIf config.numlock-boot.enable ''
        ${pkgs.numlockx}/bin/numlockx on
      '';

    # ── Disable TPM ─────────────────────────────────────────────────
    security.tpm2.enable = false;

    boot = {
      # ── TPM causes hangs - disable it ─────────────────────────────
      blacklistedKernelModules = [ "tpm" "tpm_tis" "tpm_crb" ];

      # ── Silent boot ───────────────────────────────────────────────
      consoleLogLevel = 0;

      # ── Tmpfs ─────────────────────────────────────────────────────
      # tmp.tmpfsSize = "25%";
      tmp.cleanOnBoot = false;
      tmp.useTmpfs = true;

      # ── KERNELS ───────────────────────────────────────────────────
      # kernelPackages = pkgs.linuxPackages_xanmod;
      kernelPackages = pkgs.linuxPackages_latest;

      # ── Plymouth for boot splash ──────────────────────────────────
      plymouth = {
        enable = true;
        theme = "breeze";
      };

      # ── Bootloader ────────────────────────────────────────────────
      loader = {
        systemd-boot = {
          configurationLimit = 10;
          consoleMode = "max";
          editor = true;
          enable = true;
          memtest86.enable = true;
        };
        efi.canTouchEfiVariables = true;
        timeout = 3;
      };

      # ── Plymouth initrd setup ─────────────────────────────────────
      initrd = {
        systemd.enable = true;
        verbose = false;
      };
    };
  };
}
