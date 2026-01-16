{ config, pkgs, lib, ... }:

let
  my-nix = pkgs.writeScriptBin "my-nix" ''
    #!/usr/bin/env bash
    # Tolga Erok - NixOS System Management
    # Updated: 15 Jan 2026

    BLUE=$'\033[0;34m'
    CYAN=$'\033[0;36m'
    GREEN=$'\033[0;32m'
    RED=$'\033[0;31m'
    YELLOW=$'\033[1;33m'
    NC=$'\033[0m'

    # Execute command with visual feedback
    run() {
      echo -e "''${YELLOW}▶ $*''${NC}"
      if sudo bash -c "$*"; then
        echo -e "''${GREEN}✓ Success''${NC}\n"
      else
        echo -e "''${RED}✗ Failed''${NC}\n"
        read -p "Press Enter to continue..."
      fi
    }

    # Display menu
    menu() {
      clear
      echo -e "''${BLUE}╔════════════════════════════════════════════════════════════════╗''${NC}"
      echo -e "''${BLUE}║                    NixOS System Management                     ║''${NC}"
      echo -e "''${BLUE}╚════════════════════════════════════════════════════════════════╝''${NC}"
      echo ""
      echo -e "''${CYAN}── System Rebuild ──''${NC}"
      echo -e " ''${GREEN}1''${NC})  nixos-rebuild switch          Apply configuration changes"
      echo -e " ''${GREEN}2''${NC})  nixos-rebuild test            Test config without switching"
      echo -e " ''${GREEN}3''${NC})  nixos-rebuild switch --upgrade   Update & rebuild system"
      echo ""
      echo -e "''${CYAN}── Cleanup & Optimization ──''${NC}"
      echo -e " ''${GREEN}4''${NC})  Collect garbage (-d)          Remove old packages"
      echo -e " ''${GREEN}5''${NC})  Delete old generations        Clean boot menu entries"
      echo -e " ''${GREEN}6''${NC})  Optimize Nix store            Deduplicate files"
      echo -e " ''${GREEN}7''${NC})  Full cleanup                  All-in-one maintenance"
      echo ""
      echo -e "''${CYAN}── System Info ──''${NC}"
      echo -e " ''${GREEN}8''${NC})  List generations              Show system versions"
      echo -e " ''${GREEN}9''${NC})  Show disk usage               Nix store size"
      echo -e "''${GREEN}10''${NC})  List installed packages       User packages"
      echo ""
      echo -e "''${CYAN}── Advanced ──''${NC}"
      echo -e "''${GREEN}11''${NC})  Check store issues            Find broken symlinks"
      echo -e "''${GREEN}12''${NC})  Update channels               Refresh package sources"
      echo -e "''${GREEN}13''${NC})  Rollback to previous gen     Undo last rebuild"
      echo ""
      echo -e "''${RED}0''${NC})  Exit"
      echo ""
      echo -e "''${BLUE}────────────────────────────────────────────────────────────────''${NC}"
      echo -n -e "''${YELLOW}Select option: ''${NC}"
    }

    # Full system cleanup
    full_cleanup() {
      echo -e "''${CYAN}Starting full system cleanup...''${NC}\n"
      run "nix-collect-garbage --delete-old"
      run "nix-collect-garbage -d"
      run "nix store optimise"
      run "/run/current-system/bin/switch-to-configuration boot"
      run "fstrim -av"
      echo -e "''${GREEN}✓ Cleanup complete!''${NC}"
      read -p "Press Enter to continue..."
    }

    # List generations with details
    list_gens() {
      echo -e "''${CYAN}System Generations:''${NC}\n"
      sudo nix-env --profile /nix/var/nix/profiles/system --list-generations
      echo ""
      read -p "Press Enter to continue..."
    }

    # Delete specific generation
    delete_gen() {
      list_gens
      echo -n -e "''${YELLOW}Enter generation number to delete (0 to cancel): ''${NC}"
      read gen
      if [[ "$gen" =~ ^[0-9]+$ ]] && [ "$gen" -gt 0 ]; then
        run "nix-env --profile /nix/var/nix/profiles/system --delete-generations $gen"
        run "/run/current-system/bin/switch-to-configuration boot"
      fi
    }

    # Show disk usage
    disk_usage() {
      echo -e "''${CYAN}Nix Store Disk Usage:''${NC}\n"
      du -sh /nix/store 2>/dev/null
      echo ""
      df -h /nix/store 2>/dev/null | tail -n1
      echo ""
      read -p "Press Enter to continue..."
    }

    # Check for broken symlinks
    check_store() {
      echo -e "''${CYAN}Checking for broken symlinks in /nix/store...''${NC}\n"
      broken=$(find /nix/store -xtype l 2>/dev/null | wc -l)
      if [ "$broken" -eq 0 ]; then
        echo -e "''${GREEN}✓ No broken symlinks found''${NC}"
      else
        echo -e "''${YELLOW}Found $broken broken symlinks''${NC}"
        echo -e "''${YELLOW}Run option 4 (Collect garbage) to clean up''${NC}"
      fi
      echo ""
      read -p "Press Enter to continue..."
    }

    # Main loop
    while true; do
      menu
      read choice
      echo ""
      
      case $choice in
        1) run "nixos-rebuild switch" ;;
        2) run "nixos-rebuild test" ;;
        3) run "nixos-rebuild switch --upgrade" ;;
        4) run "nix-collect-garbage -d" ;;
        5) delete_gen ;;
        6) run "nix store optimise" ;;
        7) full_cleanup ;;
        8) list_gens ;;
        9) disk_usage ;;
        10) run "nix-env -q"; read -p "Press Enter..." ;;
        11) check_store ;;
        12) run "nix-channel --update" ;;
        13) 
          echo -e "''${YELLOW}Rolling back to previous generation...''${NC}"
          run "nixos-rebuild switch --rollback"
          ;;
        0) 
          echo -e "''${CYAN}Goodbye!''${NC}"
          exit 0 
          ;;
        *) 
          echo -e "''${RED}Invalid choice!''${NC}"
          sleep 1
          ;;
      esac
    done
  '';

in { environment.systemPackages = [ my-nix ]; }
