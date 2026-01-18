{ config, pkgs, lib, ... }: {
  imports = [
    ./custom/check-nvidia.nix
    ./custom/delete-gens.nix
    ./custom/display-linuxtweaks.nix
    ./custom/my-gitup.nix
    ./custom/mynix.nix
    ./custom/myscld.nix
    ./custom/new-smb-user.nix
  ];

  # UNFREE_ALLOWANCE
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core essentials
    curl
    direnv
    distrobox
    efibootmgr
    git
    killall
    libnotify
    lsd
    nfs-utils
    pipx
    util-linux
    vim
    wget

    # Multimedia (streamlined)
    ffmpeg-full
    imagemagick
    mpv
    pavucontrol
    pipewire
    wireplumber

    # Productivity
    megasync
    variety
    wpsoffice

    # Compression (essential only)
    gzip
    p7zip
    unzip
    zip
    zstd

    # Backup
    restic

    # Development
    fastfetch
    bc
    gcc
    ncdu
    nix-direnv
    nixfmt-classic
    nixfmt-rfc-style
    nixpkgs-fmt
    pciutils
    pkg-config
    ripgrep
    vscode
    vscode-extensions.brettm12345.nixfmt-vscode
    vscode-extensions.foxundermoon.shell-format
    vscode-extensions.mkhl.direnv

    # Python development
    # python3Full
    python312Packages.pip
    python312Packages.setuptools
    python312Packages.virtualenv

    # Bash tools
    shellcheck
    shfmt

    # System utilities & fun
    duf
    figlet
    fortune
    lolcat
    rofimoji
    yad
    zenity

    # Required libraries (minimal)
    gtk-engine-murrine
    gtk3
    libGL
  ];
}
