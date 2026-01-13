{ config, pkgs, lib, ... }:

let
  genDel = pkgs.writeShellScriptBin "gen-del" ''
    #!/usr/bin/env bash
    # Tolga erok
    # 13 Jan 26
    # delete old nixos generations with full system info
    # Version: 2

    red='\033[0;31m'
    green='\033[0;32m'
    yellow='\033[1;33m'
    blue='\033[0;34m'
    cyan='\033[0;36m'
    reset='\033[0m'

    # get current generation
    current_gen=$(readlink -f /nix/var/nix/profiles/system | grep -oE '[0-9]+$')

    # get kernel info from generations
    get_kernel_info() {
    	local gen=$1
    	local gen_path="/nix/var/nix/profiles/system-''${gen}-link"

    	if [[ -L "$gen_path" ]]; then
    		local kernel_path=$(readlink -f "$gen_path/kernel")
    		if [[ -n "$kernel_path" ]]; then
    			# extract full kernel package name from store path
    			# /nix/store/xxx-linux-6.12.8-xanmod1/bzImage -> linux-6.12.8-xanmod1
    			basename "$(dirname "$kernel_path")" | sed 's/^[^-]*-//'
    		else
    			echo "unknown"
    		fi
    	else
    		echo "n/a"
    	fi
    }

    # list all generations with kernel info
    echo -e "''${cyan}═══════════════════════════════════════════════════════════════════════''${reset}"
    echo -e "''${cyan}                LinuxTweaks NixOS Generation Manager''${reset}"
    echo -e "''${cyan}═══════════════════════════════════════════════════════════════════════''${reset}"
    echo ""
    printf "''${cyan}%-4s %-20s %-30s''${reset}\n" "Gen" "Date" "Kernel"
    echo -e "''${cyan}───────────────────────────────────────────────────────────────────────''${reset}"

    while IFS= read -r line; do
    	gen_num=$(echo "$line" | awk '{print $1}')
    	date=$(echo "$line" | awk '{print $2, $3}')

    	if [[ "$gen_num" =~ ^[0-9]+$ ]]; then
    		kernel=$(get_kernel_info "$gen_num")
    		[[ -z "$kernel" ]] && kernel="unknown"

    		if [[ "$line" == *"(current)"* ]]; then
    			printf "''${green}➜ %-2s %-20s %-30s (current)''${reset}\n" "$gen_num" "$date" "$kernel"
    		elif [[ "$gen_num" -gt "$current_gen" ]]; then
    			printf "''${blue}  %-2s %-20s %-30s''${reset}\n" "$gen_num" "$date" "$kernel"
    		else
    			printf "''${yellow}  %-2s %-20s %-30s''${reset}\n" "$gen_num" "$date" "$kernel"
    		fi
    	fi
    done < <(${pkgs.nix}/bin/nix-env --list-generations --profile /nix/var/nix/profiles/system)

    echo ""
    echo -e "''${cyan}Current generation: ''${green}$current_gen''${reset}"
    echo ""
    read -p "Press Enter to continue..."

    # get user input
    echo ""
    echo -e "''${yellow}Examples: '1-10' or '1 5 7 15-20' or 'all' or 'old' (keep last 5)''${reset}"
    read -p "Enter generations to delete: " input

    # index input
    generations_to_delete=()

    if [[ "$input" == "all" ]]; then

    	# delete all except current
    	while IFS= read -r line; do
    		gen=$(echo "$line" | awk '{print $1}')
    		[[ "$gen" =~ ^[0-9]+$ ]] && [[ "$gen" != "$current_gen" ]] && generations_to_delete+=("$gen")
    	done < <(${pkgs.nix}/bin/nix-env --list-generations --profile /nix/var/nix/profiles/system)
    elif [[ "$input" == "old" ]]; then

    	# keep only last 5 generations for safty
    	keep_count=5
    	gens=($(${pkgs.nix}/bin/nix-env --list-generations --profile /nix/var/nix/profiles/system | awk '{print $1}' | grep '^[0-9]*$' | sort -n))
    	total=''${#gens[@]}
    	if [[ $total -gt $keep_count ]]; then
    		for ((i = 0; i < total - keep_count; i++)); do
    			[[ "''${gens[i]}" != "$current_gen" ]] && generations_to_delete+=("''${gens[i]}")
    		done
    	fi
    else
    	# index ranges like "1-10" and single numbers
    	for item in $input; do
    		if [[ "$item" =~ ^([0-9]+)-([0-9]+)$ ]]; then
    			start="''${BASH_REMATCH[1]}"
    			end="''${BASH_REMATCH[2]}"
    			for ((i = start; i <= end; i++)); do
    				[[ "$i" != "$current_gen" ]] && generations_to_delete+=("$i")
    			done
    		elif [[ "$item" =~ ^[0-9]+$ ]]; then
    			[[ "$item" != "$current_gen" ]] && generations_to_delete+=("$item")
    		fi
    	done
    fi

    # check if anything to delete
    if [[ ''${#generations_to_delete[@]} -eq 0 ]]; then
    	echo -e "''${red}No valid generations to delete''${reset}"
    	exit 1
    fi

    # show what will be deleted with kernel info
    echo ""
    echo -e "''${yellow}Generations marked for deletion:''${reset}"
    for gen in "''${generations_to_delete[@]}"; do
    	kernel=$(get_kernel_info "$gen")
    	printf "  ''${red}%-2s''${reset} - %s\n" "$gen" "$kernel"
    done

    # are you sure?
    echo ""
    read -p "Confirm deletion? (y/N): " confirm

    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    	echo -e "''${cyan}Deletion cancelled''${reset}"
    	exit 0
    fi

    # delete generations
    echo ""
    deleted=0
    failed=0
    for gen in "''${generations_to_delete[@]}"; do
    	if sudo ${pkgs.nix}/bin/nix-env --delete-generations --profile /nix/var/nix/profiles/system "$gen" 2>/dev/null; then
    		echo -e "''${green}✓''${reset} Deleted generation $gen"
    		((deleted++))
    	else
    		echo -e "''${red}✗''${reset} Failed to delete generation $gen"
    		((failed++))
    	fi
    done

    echo ""
    echo -e "''${cyan}═══════════════════════════════════════════════════════''${reset}"
    echo -e "''${green}Deleted: $deleted''${reset} | ''${red}Failed: $failed''${reset}"
    echo -e "''${cyan}═══════════════════════════════════════════════════════''${reset}"

    # garbage collection
    if [[ $deleted -gt 0 ]]; then
    	echo ""
    	read -p "Run garbage collection now? (Y/n): " gc_confirm
    	if [[ ! "$gc_confirm" =~ ^[nN]$ ]]; then
    		echo -e "''${cyan}Running garbage collection...''${reset}"
    		sudo ${pkgs.nix}/bin/nix-collect-garbage
    		echo -e "''${green}Garbage collection completed''${reset}"
    	fi
    fi

    # update boot
    echo ""
    read -p "Update boot configuration? (Y/n): " boot_confirm
    if [[ ! "$boot_confirm" =~ ^[nN]$ ]]; then
    	echo -e "''${cyan}Updating boot configuration...''${reset}"
    	sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot
    	echo -e "''${green}Boot configuration updated''${reset}"
    fi
  '';
in { environment.systemPackages = [ genDel ]; }
