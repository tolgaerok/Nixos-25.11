{ lib, pkgs, config, ... }:
with lib;
let cfg = config.drivers.nvidia;
in {
  options.drivers.nvidia = { 
    enable = mkEnableOption "Enable Nvidia Drivers"; 
  };
  
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    
    hardware.nvidia = {
      nvidiaPersistenced = true;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        libva-utils
      ];
    };

    # System packages
    environment.systemPackages = with pkgs; [
      symbola
      egl-wayland
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
    ];
  };
}