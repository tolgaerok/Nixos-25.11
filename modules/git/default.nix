{ config, pkgs, lib, ... }: {

  # Git configuration
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