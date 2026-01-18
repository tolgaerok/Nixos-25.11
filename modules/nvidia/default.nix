{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.drivers.nvidia;

in
{
  options.drivers.nvidia = {
    enable = mkEnableOption "Enable Nvidia Drivers";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaPersistenced = true;
      nvidiaSettings = true;
      open = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.latest;

      powerManagement.enable = true;
      powerManagement.finegrained = false;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [

        # vaapiVdpau
        intel-media-driver # Intel iGPU accel
        intel-vaapi-driver # Intel VA-API
        libva
        libva-utils
        libva-vdpau-driver
        libvdpau
        libvdpau-va-gl
        nvidia-vaapi-driver
        vdpauinfo
      ];
    };

    # System packages
    environment.systemPackages = with pkgs; [
      egl-wayland
      symbola
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
    ];
  };
}
