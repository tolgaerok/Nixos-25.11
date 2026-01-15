{ config, pkgs, lib, ... }:

{
  imports = [
    ./boot
    ./docker
    ./firewall
    ./flatpaks
    ./fonts
    ./git
    ./hw-clock
    ./locale
    ./memory
    ./mnt
    ./networking
    ./nix
    ./nvidia
    ./pkgs
    ./portals
    ./printer
    ./programs
    ./samba
    ./services
    ./sound
    ./systemD
    ./users
  ];

}
