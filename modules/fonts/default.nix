{ pkgs, ... }:
let
  username = "tolga";

  wpsFonts = pkgs.stdenv.mkDerivation {
    pname = "wps-fonts";
    version = "latest";
    src = pkgs.fetchzip {
      url = "https://github.com/tolgaerok/fonts-tolga/raw/main/WPS-FONTS.zip";
      sha256 = "Pzl1+g8vaRLm1c6A0fk81wDkFOnuvtohg/tW+G1nNQo=";
      stripRoot = false;
    };
    installPhase = ''
      mkdir -p $out/share/fonts
      cp -r $src/* $out/share/fonts/
      if [ -f "$out/share/fonts/WEBDINGS.TTF" ]; then
        mv "$out/share/fonts/WEBDINGS.TTF" "$out/share/fonts/Webdings.ttf"
      fi
    '';
  };
in {
  _module.args.username = username;

  fonts.packages = with pkgs; [
    corefonts
    dejavu_fonts
    fira-code
    fira-code-symbols
    fira-sans
    font-awesome
    hackgen-nf-font
    ibm-plex
    inter
    jetbrains-mono
    liberation_ttf
    lilex
    maple-mono.NF
    material-icons
    minecraftia
    nerd-fonts.blex-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.im-writing
    nerd-fonts.jetbrains-mono
    nerd-fonts.lilex
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
    powerline-fonts
    roboto
    roboto-mono
    symbola
    terminus_font
    victor-mono
    wineWowPackages.fonts
    wpsFonts
  ];

  environment.systemPackages = with pkgs; [ fontconfig wpsFonts ];

  system.activationScripts.updateFontCache = ''
    echo "Updating font cache..."
    ${pkgs.fontconfig}/bin/fc-cache -f -v
  '';
}

# /home/tolga/.local/share/fonts
