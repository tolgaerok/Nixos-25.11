#!/bin/bash
# Tolga Erok
# My Git Repository Clone & Setup
# Version: 1.0
# Date: 12 Jan 2026
# Version: 1.5

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
cyan='\033[0;36m'
reset='\033[0m'

git_dir="$HOME/MyGitStuff"

echo -e "${cyan}╔════════════════════════════════════════════════════╗${reset}"
echo -e "${cyan}║         MY GIT REPOSITORY CLONE & SETUP            ║${reset}"
echo -e "${cyan}╚════════════════════════════════════════════════════╝${reset}"
echo ""

# verify ssh key exists
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
	echo -e "${red}✗${reset} SSH key not found. Run setup-ssh-keys.sh first"
	exit 1
fi

# display public key for verification
echo -e "${yellow}→${reset} Your SSH public key:"
echo -e "${blue}$(cat ~/.ssh/id_ed25519.pub)${reset}"
echo ""
echo -e "${yellow}→${reset} Make sure this key is added to GitHub and GitLab"
echo -e "${yellow}→${reset} Press Enter to continue..."
read

# test my github connection
echo -e "${yellow}→${reset} Testing GitHub connection..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
	echo -e "${green}✓${reset} GitHub SSH connection successful"
else
	echo -e "${red}✗${reset} GitHub SSH connection failed"
	echo -e "${yellow}→${reset} Add your key at: https://github.com/settings/keys"
	exit 1
fi

# test my gitlab connection
echo -e "${yellow}→${reset} Testing GitLab connection..."
if ssh -T git@gitlab.com 2>&1 | grep -q "Welcome"; then
	echo -e "${green}✓${reset} GitLab SSH connection successful"
else
	echo -e "${red}✗${reset} GitLab SSH connection failed"
	echo -e "${yellow}→${reset} Add your key at: https://gitlab.com/-/profile/keys"
	exit 1
fi

# create my directories
if [ ! -d "$git_dir" ]; then
	echo -e "${yellow}→${reset} Creating directory: $git_dir"
	mkdir -p "$git_dir"
	echo -e "${green}✓${reset} Directory created"
else
	echo -e "${green}✓${reset} Directory exists: $git_dir"
fi

cd "$git_dir" || exit 1

# clone my github repo
if [ ! -d "$git_dir/Nixos-25.11" ]; then
	echo -e "${yellow}→${reset} Cloning GitHub repo: Nixos-25.11..."
	git clone git@github.com:tolgaerok/Nixos-25.11.git
	echo -e "${green}✓${reset} GitHub repo cloned"
else
	echo -e "${green}✓${reset} GitHub repo exists, pulling latest..."
	cd "$git_dir/Nixos-25.11"
	git pull
	cd "$git_dir"
fi

# clone my gitlab repo
if [ ! -d "$git_dir/nixos-25-11-kde-nvidia" ]; then
	echo -e "${yellow}→${reset} Cloning GitLab repo: nixos-25-11-kde-nvidia..."
	git clone git@gitlab.com:kingtolga/nixos-25-11-kde-nvidia.git
	echo -e "${green}✓${reset} GitLab repo cloned"
else
	echo -e "${green}✓${reset} GitLab repo exists, pulling latest..."
	cd "$git_dir/nixos-25-11-kde-nvidia"
	git pull
	cd "$git_dir"
fi

# test
echo ""
echo -e "${cyan}Repository Status:${reset}"
ls -la "$git_dir"

echo ""
echo -e "${green}✓${reset} Git configuration:"
git config --list | grep -E "user\.|credential\.|init\."

echo ""
echo -e "${cyan}╚════════════════════════════════════════════════════╝${reset}"
echo -e "${green}Setup complete!${reset}"
echo ""
echo -e "GitHub repo:  ${blue}$git_dir/Nixos-25.11${reset}"
echo -e "GitLab repo:  ${blue}$git_dir/nixos-25-11-kde-nvidia${reset}"
