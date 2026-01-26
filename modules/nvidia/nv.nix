{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.drivers.nvidia;
  # custom 590.44.01 driver build
  nvidia590 = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "590.44.01";
    sha256_64bit = "sha256-VbkVaKwElaazojfxkHnz/nN/5olk13ezkw/EQjhKPms=";
    sha256_aarch64 = lib.fakeHash;
    openSha256 = "sha256-ft8FEnBotC9Bl+o4vQA1rWFuRe7gviD/j1B8t0MRL/o=";
    settingsSha256 = "sha256-wVf1hku1l5OACiBeIePUMeZTWDQ4ueNvIk6BsW/RmF4=";
    persistencedSha256 = "sha256-nHzD32EN77PG75hH9W8ArjKNY/7KY6kPKSAhxAWcuS4=";
  };
in {
  options.drivers.nvidia = { enable = mkEnableOption "Enable Nvidia Drivers"; };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaPersistenced = true;
      nvidiaSettings = true;
      open = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      package = nvidia590;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva
        libva-utils
        libva-vdpau-driver
        libvdpau
        libvdpau-va-gl
        nvidia-vaapi-driver
        vdpauinfo
      ];
    };

    environment.systemPackages = with pkgs; [
      egl-wayland
      symbola
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
    ];
  };
}
