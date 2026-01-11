{ config, lib, pkgs, ... }: {
  # Programs
  programs.bash.enable = true;
  programs.firefox.enable = true;
  programs.ssh.startAgent = true;
}
