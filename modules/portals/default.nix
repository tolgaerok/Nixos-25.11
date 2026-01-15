{ pkgs, ... }: {
  # KDE Plasma 6 Portal Configuration
  xdg.portal = {
    enable = true;
    extraPortals = [

      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "kde";
  };
}
