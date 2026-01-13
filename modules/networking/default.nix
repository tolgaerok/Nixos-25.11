{ config, lib, pkgs, ... }: {

  # Networking
  networking = {
    hostName = "G4-nixos";
    firewall = {
      trustedInterfaces = [ "zt*" ]; # Trust ZeroTier interfaces
      allowedTCPPorts = [ config.services.prometheus.exporters.smartctl.port ];
    };
  };

}
