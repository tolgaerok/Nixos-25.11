{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.drivers.nvidia;
  # custom 590.44.01 driver build
  #nvidia590 = config.boot.kernelPackages.nvidiaPackages.mkDriver {
  #  version = "590.44.01";
  #  sha256_64bit = "sha256-VbkVaKwElaazojfxkHnz/nN/5olk13ezkw/EQjhKPms=";
  #  sha256_aarch64 = lib.fakeHash;
  #  openSha256 = "sha256-ft8FEnBotC9Bl+o4vQA1rWFuRe7gviD/j1B8t0MRL/o=";
  #  settingsSha256 = "sha256-wVf1hku1l5OACiBeIePUMeZTWDQ4ueNvIk6BsW/RmF4=";
  #  persistencedSha256 = "sha256-nHzD32EN77PG75hH9W8ArjKNY/7KY6kPKSAhxAWcuS4=";
  #};

  # custom 590.48.01 driver build
  nvidia590 = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "590.48.01";
    sha256_64bit = "sha256-ueL4BpN4FDHMh/TNKRCeEz3Oy1ClDWto1LO/LWlr1ok=";
    sha256_aarch64 = "sha256-FOz7f6pW1NGM2f74kbP6LbNijxKj5ZtZ08bm0aC+/YA=";
    openSha256 = "sha256-hECHfguzwduEfPo5pCDjWE/MjtRDhINVr4b1awFdP44=";
    settingsSha256 = "sha256-NWsqUciPa4f1ZX6f0By3yScz3pqKJV1ei9GvOF8qIEE=";
    persistencedSha256 = "sha256-wsNeuw7IaY6Qc/i/AzT/4N82lPjkwfrhxidKWUtcwW8=";
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
