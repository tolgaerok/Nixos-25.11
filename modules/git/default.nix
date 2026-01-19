{ config, pkgs, lib, ... }:
with lib;
let
  # SSH tools paths
  sshAdd = "${pkgs.openssh}/bin/ssh-add";
  sshAgent = "${pkgs.openssh}/bin/ssh-agent";
  sshKeygen = "${pkgs.openssh}/bin/ssh-keygen";

  # Script: generate SSH key if missing
  genSshKey = pkgs.writeShellScriptBin "gen-ssh-key" ''
    set -e
    if [[ -f $HOME/.ssh/id_ed25519 ]]; then
      echo "🔐 SSH key already exists."
      exit 0
    fi
    ${sshKeygen} -t ed25519 -C "$1" -f "$HOME/.ssh/id_ed25519"
    eval $(${sshAgent} -s)
    ${sshAdd} $HOME/.ssh/id_ed25519
    echo "🔑 SSH key generated and added to agent."
  '';
in {

  environment.systemPackages = with pkgs;
    [
      # Custom
      genSshKey
    ];

  # Git configuration...
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Tolga Erok";
        email = "kingtolga@gmail.com";
      };
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };

  # SSH client config
  programs.ssh = {
    extraConfig = ''
      Host github.com
        User git
        IdentityFile ~/.ssh/id_ed25519
        
      Host gitlab.com
        User git
        IdentityFile ~/.ssh/id_ed25519
    '';
  };

  environment.shellInit = ''
    git config --global user.name "Tolga Erok" 2>/dev/null || true
    git config --global user.email "kingtolga@gmail.com" 2>/dev/null || true
  '';
}

# mkdir -p ~/.ssh && chmod 700 ~/.ssh
# ssh-keygen -t ed25519 -C "kingtolga@gmail.com" -f ~/.ssh/id_ed25519
# cat ~/.ssh/id_ed25519.pub  # Copy this to GitHub/GitLab
# ssh -T git@github.com
# ssh -T git@gitlab.com
# git config --list

# Create directory
# mkdir -p ~/MyGitStuff
# cd ~/MyGitStuff

# Clone GitHub repo (SSH)
# git clone git@github.com:tolgaerok/Nixos-25.11.git

# Clone GitLab repo (SSH)
# git clone git@gitlab.com:kingtolga/nixos-25-11-kde-nvidia.git

# Verify
# ls -la ~/MyGitStuff

# GitHub repo
# cd ~/MyGitStuff/Nixos-25.11
# git pull
# git push

# GitLab repo
# cd ~/MyGitStuff/nixos-25-11-kde-nvidia
# git pull
# git push
