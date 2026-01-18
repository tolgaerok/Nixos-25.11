{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./boot
    ./firewall
    ./flatpaks
    ./fonts
    ./kde
    ./locale
    ./memory
    ./mnt
    ./networking
    ./nix
    ./nvidia
    ./pkgs
    ./printer
    ./programs
    ./samba
    ./services
    ./sound
    ./systemD
    ./users
    # ./docker
    ./git
    #./hw-clock
    # ./portals
  ];
}
