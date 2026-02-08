{ config, lib, pkgs, ... }: {
  # flatpak with automated dark theme
  services = { flatpak = { enable = true; }; };

  environment.systemPackages = with pkgs; [
    # flatpak & desktop portal
    flatpak
    gnomeExtensions.mock-tray
    xdg-desktop-portal
    xdg-desktop-portal-gtk
  ];

  system.activationScripts.installFlatpaks.text = ''
        # add flathub remote
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        
        # install flatpak applications
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes com.github.wwmm.easyeffects
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub com.dec05eba.gpu_screen_recorder
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub com.discordapp.Discord
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub com.github.tchx84.Flatseal
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub com.google.Chrome
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub im.riot.Riot
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub io.github.aandrew_me.ytdn
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub io.github.flattool.Warehouse
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub io.github.giantpinkrobots.flatsweep
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub org.dupot.easyflatpak
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub org.gnome.Rhythmbox3
        ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub org.mozilla.firefox
        
        # setup dark theme for user tolga
        mkdir -p /home/tolga/.config/gtk-3.0
        mkdir -p /home/tolga/.config/gtk-4.0
        
        cat > /home/tolga/.config/gtk-3.0/settings.ini << 'EOF'
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-theme-name=Adwaita-dark
    EOF

        cat > /home/tolga/.config/gtk-4.0/settings.ini << 'EOF'
    [Settings]
    gtk-application-prefer-dark-theme=1
    EOF

        chown -R tolga:users /home/tolga/.config/gtk-3.0
        chown -R tolga:users /home/tolga/.config/gtk-4.0
        
        # apply dark theme to all flatpak apps
        ${pkgs.flatpak}/bin/flatpak override --system --filesystem=xdg-config/gtk-3.0:ro
        ${pkgs.flatpak}/bin/flatpak override --system --filesystem=xdg-config/gtk-4.0:ro
        ${pkgs.flatpak}/bin/flatpak override --system --env=GTK_THEME=Adwaita:dark
  '';
}
