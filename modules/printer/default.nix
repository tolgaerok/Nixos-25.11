{ config, lib, pkgs, ... }:
let
  extraBackends = [ pkgs.epkowa ];

  printerDrivers =
    [ pkgs.gutenprint pkgs.gutenprintBin pkgs.hplip pkgs.hplipWithPlugin ];
in {

  # Scanner drivers
  hardware.sane = {
    enable = true;
    extraBackends = extraBackends;
  };

  # Printing with CUPS
  services.printing = {
    enable = true;
    drivers = printerDrivers;
  };

  # Network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    allowInterfaces = [ "wlp2s0" ]; # Prevent Docker spam
    denyInterfaces = [ "docker0" "br-*" "veth*" ];
  };
}
