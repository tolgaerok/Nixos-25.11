{ config, lib, pkgs, ... }: {
  # Flatpak
  services.flatpak.enable = true;

  system.activationScripts.installFlatpaks.text = ''
    ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub com.dec05eba.gpu_screen_recorder
    ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub com.github.tchx84.Flatseal
    ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub io.github.aandrew_me.ytdn
    ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub io.github.flattool.Warehouse
    ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub io.github.giantpinkrobots.flatsweep
    ${pkgs.flatpak}/bin/flatpak install --system --noninteractive --assumeyes flathub org.dupot.easyflatpak
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  '';
}
