{ config, lib, pkgs, ... }: {
  # Programs

  # programs.firefox.enable = true;   # PRINTING ISSUES FUCKED USE FLATPAK VERSION INSTEAD
  programs.bash.enable = true;
  programs.ssh.startAgent = true;
}
