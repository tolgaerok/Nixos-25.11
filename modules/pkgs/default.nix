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
    ./custom/new-smb-user.nix

  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core Tools
    btrfs-progs
    busybox
    curl
    direnv
    distrobox
    efibootmgr
    figlet
    fortune
    git
    killall
    libnotify
    lsd
    pipx
    shadow
    util-linux
    vim
    wget

    # Spell Check
    aspell
    aspellDicts.en
    hunspell
    hunspellDicts.en_AU
    rPackages.hunspell

    # Multimedia
    audacity
    ffmpeg-full
    ffmpegthumbnailer
    gimp3-with-plugins
    imagemagick
    imagemagickBig
    libdvdcss
    libdvdread
    libopus
    libvorbis
    mediainfo
    mediainfo-gui
    mpg123
    mplayer
    mpv
    ocamlPackages.gstreamer
    pavucontrol
    pipewire
    pulseaudio
    scdl
    simplescreenrecorder
    video-trimmer

    # Themes and icons
    adwaita-icon-theme
    adwaita-qt
    bibata-cursors
    catppuccin-gtk
    papirus-icon-theme

    # KDE / Qt
    # kdePackages.kpipewire
    # libsForQt5.kpipewire
    kdePackages.kate
    kdePackages.kde-cli-tools
    kdePackages.kwrited
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum # kvantum
    kdePackages.qtwayland
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum # kvantum
    qt5.qtbase
    qt5.qtwayland

    # Browsers
    # google-chrome

    # Office / Productivity
    megasync
    variety
    wpsoffice
    # element-desktop
    system-config-printer
    gsettings-desktop-schemas
    pkg-config
    cups

    # Compression & Archives
    atool
    file
    gzip
    lz4
    lzip
    lzo
    lzop
    p7zip
    rar
    rzip
    unzip
    xz
    zip
    zstd

    # Network & File Systems
    cifs-utils
    firewalld-gui
    nfs-utils
    nvme-cli

    # Backup Tools
    borgbackup
    restic
    restique

    # Development
    gcc
    mesa-demos
    inxi
    libeatmydata
    lshw
    ncdu
    nix-direnv
    nix-direnv
    nixfmt-classic
    nixfmt-rfc-style
    nixpkgs-fmt
    nixos-option
    pciutils
    pkg-config
    rPackages.convert
    ripgrep
    ripgrep-all
    ruby
    socat
    vscode
    vscode-extensions.brettm12345.nixfmt-vscode
    vscode-extensions.foxundermoon.shell-format
    vscode-extensions.mkhl.direnv

    # Bash formatting
    shfmt
    shellcheck

    # System Info & Fun
    duf
    fastfetch
    lolcat
    nordic
    rofimoji
    yad
    zenity

    # Flatpak & Desktop Portal
    flatpak
    gnomeExtensions.mock-tray
    xdg-desktop-portal

    # Custom Tools
    genSshKey

    # Libraries & Dev Headers
    adwaita-icon-theme
    atk
    cairo
    glib
    glib.dev
    gobject-introspection
    gobject-introspection.dev
    gtk3
    gtk3.dev
    gtk-engine-murrine # for gtk themes
    gtk4
    libGL
    libxkbcommon
    pango
    zlib
  ];
}
