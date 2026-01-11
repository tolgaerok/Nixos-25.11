{ config, lib, pkgs, ... }: {

  # Networking
  networking.hostName = "G4-nixos";
  networking.networkmanager.enable = true;

}
