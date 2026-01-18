{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "G4-nixos";

    networkmanager = {
      enable = true;
      appendNameservers = [ "1.1.1.1" "8.8.8.8" ];

    };

    extraHosts = ''
      # Local system
      127.0.0.1       localhost HP-G1-800

      # Currently Active Devices (from ARP/Avahi scan)
      192.168.0.1     router mygateway.home
      192.168.0.7     Laser NPI15D87F HP-M601
      192.168.0.13    HP-G1-800 G4-nixos
      192.168.0.17    QNAP Jack-Sparrow
      192.168.0.18    min21THIN MINT21

      # Devices Not Currently Online (may reconnect)
      # 192.168.0.2   DIGA                      # Smart TV
      # 192.168.0.5   folio-F39                 # HP Folio
      # 192.168.0.6   iPhone                    # Dad's phone
      # 192.168.0.10  TUNCAY-W11-ENT            # Dad's PC
      # 192.168.0.11  ubuntu-server             # CasaOS
      # 192.168.0.15  KingTolga                 # my phone
      # 192.168.0.20  W11-SERVER                # Home server

      # IPv6
      ::1             localhost ip6-localhost ip6-loopback
      fe00::0         ip6-localnet
      ff00::0         ip6-mcastprefix
      ff02::1         ip6-allnodes
      ff02::2         ip6-allrouters
    '';

    firewall = {
      trustedInterfaces = [ "zt*" ]; # ZeroTier VPN (if you use it)
      allowedTCPPorts = [ config.services.prometheus.exporters.smartctl.port ];
    };
  };
}
