{
  config,
  pkgs,
  lib,
  ...
}:

# Tolga Erok
# 3/11/2023
# My personal NIXOS KDE configuration
#
#              ¯\_(ツ)_/¯
#   ███▄    █     ██▓   ▒██   ██▒    ▒█████       ██████
#   ██ ▀█   █    ▓██▒   ▒▒ █ █ ▒░   ▒██▒  ██▒   ▒██    ▒
#  ▓██  ▀█ ██▒   ▒██▒   ░░  █   ░   ▒██░  ██▒   ░ ▓██▄
#  ▓██▒  ▐▌██▒   ░██░    ░ █ █ ▒    ▒██   ██░     ▒   ██▒
#  ▒██░   ▓██░   ░██░   ▒██▒ ▒██▒   ░ ████▓▒░   ▒██████▒▒
#  ░ ▒░   ▒ ▒    ░▓     ▒▒ ░ ░▓ ░   ░ ▒░▒░▒░    ▒ ▒▓▒ ▒ ░
#  ░ ░░   ░ ▒░    ▒ ░   ░░   ░▒ ░     ░ ▒ ▒░    ░ ░▒  ░ ░
#     ░   ░ ░     ▒ ░    ░    ░     ░ ░ ░ ▒     ░  ░  ░
#           ░     ░      ░    ░         ░ ░           ░
#
#------------------ HP EliteDesk 800 G4 SFF ------------------------

# BLUE-TOOTH        REALTEK 5G
# CPU	              Intel(R) Core(TM)  i7-8700 CPU @ 3.2GHz - 4.6Ghz (Turbo) x 6 (vPro)
# i-GPU	            Intel UHD Graphics 630, Coffee Lake
# d-GPU             NVIDIA GeForce GTX 1650
# MODEL             HP EliteDesk 800 G4 SFF
# MOTHERBOARD	      Intel Q370 PCH-H—vPro
# NETWORK	          Intel Corporation Wi-Fi 6 AX210/AX211/AX411 160MHz
# RAM	              Maximum: 64 GB, DDR4-2666 (16 GB x 4)
# STORAGE           256 GB, M.2 2280, PCIe NVMe SSD
# EXPENSION SLOTS   (1) M.2 PCIe x1 2230 (for WLAN), (2) M.2 PCIe x4 2280/2230 combo (for storage)
#                   (2) PCI Express v3.0 x1, (1) PCI Express v3.0 x16 (wired as x4), (1) PCI Express v3.0 x16
# PSU               250W
# SOURCE            https://support.hp.com/au-en/document/c06047207

#---------------------------------------------------------------------
{
  imports = [
    ./hardware-configuration.nix
    ./modules

  ];

  # NVIDIA
  drivers.nvidia.enable = true;

  # UNFREE_ALLOWANCE
  nixpkgs.config.allowUnfree = true;

  # SYSTEM_VARIBLES
  environment.variables = {
    # QT_QPA_PLATFORMTHEME = "qt5ct";
    # QT_STYLE_OVERRIDE = "kvantum";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  # STATE_VERSION
  system.stateVersion = "25.11";
}

# Notes:
# sudo chown -R $(whoami):$(id -gn) /etc/nixos && sudo chmod -R 777 /etc/nixos && sudo chmod +x /etc/nixos/* && export NIXPKGS_ALLOW_INSECURE=1

# Vaccum logs
# sudo journalctl --rotate && sudo journalctl --vacuum-time=1s && journalctl --disk-usage

# Check boot times
# systemd-analyze && systemctl status plymouth-start.service && systemd-analyze blame | head -20
