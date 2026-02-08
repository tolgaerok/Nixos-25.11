{ config, pkgs, lib, ... }:

{
  imports = [
    # ./docker
    ./boot
    ./firewall
    ./flatpaks
    ./fonts
    ./git
    ./hw-clock
    ./io-optimization
    ./kde
    ./locale
    ./memory
    ./mnt
    ./networking
    ./nix
    ./nvidia/nv.nix
    ./pkgs
    ./printer
    ./programs
    ./samba
    ./services
    ./sound
    ./systemD
    ./users
  ];

  # NVIDIA
  drivers.nvidia.enable = true;

  tweaks.io-optimization = {
    enable = true;
    scx.enable = true;
    scx.scheduler = "rusty"; # or "lavd" for your VM workflow
  };

  # SYSTEM_VARIBLES
  environment.variables = {
    # wayland support
    GDK_BACKEND = "wayland,x11"; # Prefer Wayland, fallback to X11
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };
}

# Notes:
# sudo chown -R $(whoami):$(id -gn) /etc/nixos && sudo chmod -R 777 /etc/nixos && sudo chmod +x /etc/nixos/* && export NIXPKGS_ALLOW_INSECURE=1

# Vaccum logs
# sudo journalctl --rotate && sudo journalctl --vacuum-time=1s && journalctl --disk-usage

# Check boot times
# systemd-analyze && systemctl status plymouth-start.service && systemd-analyze blame | head -20
