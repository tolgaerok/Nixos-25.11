{ config, pkgs, lib, ... }:
with lib;
let
  # SSH tools paths
  sshAdd = "${pkgs.openssh}/bin/ssh-add";
  sshAgent = "${pkgs.openssh}/bin/ssh-agent";
  sshKeygen = "${pkgs.openssh}/bin/ssh-keygen";

  # Script: generate SSH key if missing
  genSshKey = pkgs.writeShellScriptBin "gen-ssh-key" ''
    set -e
    if [[ -f $HOME/.ssh/id_ed25519 ]]; then
      echo "🔐 SSH key already exists."
      exit 0
    fi
    ${sshKeygen} -t ed25519 -C "$1" -f "$HOME/.ssh/id_ed25519"
    eval $(${sshAgent} -s)
    ${sshAdd} $HOME/.ssh/id_ed25519
    echo "🔑 SSH key generated and added to agent."
  '';
in {
  imports = [
    ./custom/check-nvidia.nix
    ./custom/delete-gens.nix
    ./custom/display-linuxtweaks.nix
    ./custom/my-gitup.nix
    ./custom/mynix.nix
    ./custom/myscld.nix
    ./custom/new-smb-user.nix
  ];

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

    # Custom
    genSshKey

    # Required libraries (minimal)
    gtk-engine-murrine
    gtk3
    libGL
  ];
}
