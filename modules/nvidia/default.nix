{ lib, pkgs, config, ... }:
with lib;
let cfg = config.drivers.nvidia;

in {
  options.drivers.nvidia = { enable = mkEnableOption "Enable Nvidia Drivers"; };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [

      "nvidia"
    ];

    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaPersistenced = true;
      nvidiaSettings = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [ libva-utils ];
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
