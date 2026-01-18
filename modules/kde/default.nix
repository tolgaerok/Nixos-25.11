{ config, pkgs, lib, ... }:

{
  services = {
    # X11
    xserver = {
      enable = true;
      xkb = {
        layout = "au";
        variant = "";
      };
    };

    # Display and desktop
    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
      # defaultSession = "plasmax11";
    };
    desktopManager.plasma6.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Themes, QT pkgs and icons
    adwaita-icon-theme
    adwaita-qt
    bibata-cursors
    catppuccin-gtk
    kdePackages.kate
    kdePackages.kde-cli-tools
    kdePackages.kwrited
    kdePackages.qt6ct
    libsForQt5.qt5ct
    papirus-icon-theme
    qt5.qtbase

    # qt wayland for sddm
    kdePackages.qtmultimedia # qt6 multimedia
    kdePackages.qtwayland # qt6
    libsForQt5.qt5.qtwayland # qt5
    libsForQt5.qtmultimedia # qt5 multimedia
  ];
}
