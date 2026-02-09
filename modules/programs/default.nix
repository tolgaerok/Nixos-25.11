{ config, lib, pkgs, ... }: {

  # Programs
  programs = {
    # programs.firefox.enable = true;   # PRINTING ISSUES FUCKED USE FLATPAK VERSION INSTEAD
    bash.completion.enable = true;
    bash.enable = true;
    dconf.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    fuse.userAllowOther = true;
    git.enable = true;
    mtr.enable = true;
    ssh.startAgent = true;

    partition-manager = { enable = true; };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };

  };

}
