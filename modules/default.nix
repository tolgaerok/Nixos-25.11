{ config, pkgs, lib, ... }:

{
  imports = [

    ./boot
    ./docker
    ./firewall
    ./flatpaks
    ./fonts
    ./git
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

  ];

}
