# Tolga Erok
# List all my custom LinuxTweaks scripts and services
# 14 Jan 2026

{ config, pkgs, lib, ... }:

let
  linuxtweaks = pkgs.writeShellScriptBin "linuxtweaks" ''
    #!/usr/bin/env bash

    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'

    echo -e "\n''${BLUE}╔══════════════════════════════════════════════════════╗''${NC}"
    echo -e "''${BLUE}║         LinuxTweaks Custom Scripts & Services        ║''${NC}"
    echo -e "''${BLUE}╚══════════════════════════════════════════════════════╝''${NC}\n"

    echo -e "''${CYAN}📦 Custom Scripts:''${NC}"
    for script in check-nvidia nvidia-info nvidia-quick gitup delete-gens new-smb-user gen-ssh-key gendel; do
      if command -v $script &>/dev/null; then
        echo -e "  ''${GREEN}✓''${NC} $script → $(which $script)"
      fi
    done

    echo -e "\n''${CYAN}🔧 Activation Scripts:''${NC}"
    grep -r "activationScripts" /etc/nixos/ 2>/dev/null | grep -v ".git" | cut -d: -f1 | sort -u | while read file; do
      script_name=$(grep "activationScripts\." "$file" | sed 's/.*activationScripts\.\([^ ]*\).*/\1/' | head -1)
      echo -e "  ''${GREEN}✓''${NC} $script_name → $file"
    done

    echo -e "\n''${CYAN}⚙️  SystemD Services (linuxtweaks):''${NC}"
    systemctl list-unit-files | grep -i "linuxtweaks\|linuxTweaks" | while read unit state; do
      echo -e "  ''${GREEN}✓''${NC} $unit [$state]"
    done

    echo -e "\n''${CYAN}🐋 Custom Modules:''${NC}"
    ls /etc/nixos/modules/pkgs/custom/*.nix 2>/dev/null | while read module; do
      echo -e "  ''${GREEN}✓''${NC} $(basename $module)"
    done

    echo -e "\n''${BLUE}════════════════════════════════════════════════════''${NC}\n"
  '';
in { environment.systemPackages = [ linuxtweaks ]; }
