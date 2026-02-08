{ config, pkgs, lib, ... }: {
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "au";
        variant = "";
      };
    };
    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
    };
    desktopManager.plasma6.enable = true;
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme # GTK app icon fallback
    bibata-cursors # cursor theme
    catppuccin-gtk # GTK theme
    kdePackages.kate # text editor
    papirus-icon-theme # icon theme
  ];
}
