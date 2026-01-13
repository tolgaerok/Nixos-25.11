#!/bin/bash
# Tolga Erok
# SSH Key Generation & Configuration
# Version: 1.8a
# Date: 12 Jan 2026

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
cyan='\033[0;36m'
reset='\033[0m'

email="kingtolga@gmail.com"
ssh_dir="$HOME/.ssh"

echo -e "${cyan}╔════════════════════════════════════════════════════╗${reset}"
echo -e "${cyan}║         SSH KEY GENERATION & SETUP                 ║${reset}"
echo -e "${cyan}╚════════════════════════════════════════════════════╝${reset}"
echo ""

# create my ssh directory
if [ ! -d "$ssh_dir" ]; then
	echo -e "${yellow}→${reset} Creating .ssh directory..."
	mkdir -p "$ssh_dir"
	chmod 700 "$ssh_dir"
	echo -e "${green}✓${reset} Directory created: $ssh_dir"
else
	echo -e "${green}✓${reset} SSH directory exists: $ssh_dir"
	chmod 700 "$ssh_dir"
fi

# generate ed25519 key
if [ ! -f "$ssh_dir/id_ed25519" ]; then
	echo -e "${yellow}→${reset} Generating ED25519 key..."
	ssh-keygen -t ed25519 -C "$email" -f "$ssh_dir/id_ed25519" -N ""
	chmod 600 "$ssh_dir/id_ed25519"
	chmod 644 "$ssh_dir/id_ed25519.pub"
	echo -e "${green}✓${reset} ED25519 key created"
else
	echo -e "${green}✓${reset} ED25519 key already exists"
fi

# generate rsa key
if [ ! -f "$ssh_dir/id_rsa" ]; then
	echo -e "${yellow}→${reset} Generating RSA key (4096-bit)..."
	ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_dir/id_rsa" -N ""
	chmod 600 "$ssh_dir/id_rsa"
	chmod 644 "$ssh_dir/id_rsa.pub"
	echo -e "${green}✓${reset} RSA key created"
else
	echo -e "${green}✓${reset} RSA key already exists"
fi

# create ssh config
echo -e "${yellow}→${reset} Creating SSH config..."
cat >"$ssh_dir/config" <<EOF
Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    
Host gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519
EOF

chmod 600 "$ssh_dir/config"
echo -e "${green}✓${reset} SSH config created"

echo ""
echo -e "${cyan}Your ED25519 Public Key:${reset}"
echo -e "${blue}$(cat $ssh_dir/id_ed25519.pub)${reset}"

echo ""
echo -e "${cyan}Next Steps brother:${reset}"
echo -e "${yellow}1.${reset} Copy the key above"
echo -e "${yellow}2.${reset} Add to GitHub: ${blue}https://github.com/settings/keys${reset}"
echo -e "${yellow}3.${reset} Add to GitLab: ${blue}https://gitlab.com/-/profile/keys${reset}"

echo ""
echo -e "${cyan}Test Connections:${reset}"
echo -e "${blue}ssh -T git@github.com${reset}"
echo -e "${blue}ssh -T git@gitlab.com${reset}"

echo ""
echo -e "${cyan}╚════════════════════════════════════════════════════╝${reset}"
