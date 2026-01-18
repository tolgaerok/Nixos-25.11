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

# Notes:
# sudo pkill -9 avahi-daemon; sudo systemctl stop avahi-daemon.{service,socket}; sudo rm -rf /run/avahi-daemon; sudo mkdir -p /run/avahi-daemon; sudo chown avahi:avahi /run/avahi-daemon; sudo systemctl reset-failed avahi-daemon.service; sudo systemctl start avahi-daemon.socket; sleep 1; sudo systemctl start avahi-daemon.service; systemctl status avahi-daemon.service
