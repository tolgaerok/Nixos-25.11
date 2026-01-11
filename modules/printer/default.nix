{ config, lib, pkgs, ... }:

let
  extraBackends = [ pkgs.epkowa ];

  # Printer drivers for HP LaserJet 600 M601
  printerDrivers = [

    pkgs.gutenprint
    pkgs.gutenprintBin
    pkgs.hplip
    pkgs.hplipWithPlugin
  ];
in {
  
  # Scanner drivers
  hardware.sane = {
    enable = true;
    extraBackends = extraBackends;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Printing with CUPS
  services.printing = {
    enable = true;
    drivers = printerDrivers;
  };
}
