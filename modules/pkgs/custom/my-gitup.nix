{ config, pkgs, lib, ... }:

let
  myGitup = pkgs.writeShellScriptBin "my-gitup" ''
    #!/usr/bin/env bash
    # gitup - My NixOS config backup to GitHub & GitLab
    # Tolga Erok
    # 12/1/2026

    red='\033[0;31m'
    green='\033[0;32m'
    yellow='\033[1;33m'
    blue='\033[0;34m'
    cyan='\033[0;36m'
    magenta='\033[0;35m'
    nc='\033[0m'

    github_repo="$HOME/MyGitStuff/Nixos-25.11"
    gitlab_repo="$HOME/MyGitStuff/nixos-25-11-kde-nvidia"
    source_dir="/etc/nixos"

    echo -e "''${cyan}╔════════════════════════════════════════╗''${nc}"
    echo -e "''${cyan}║   NIXOS CONFIG BACKUP - GitHub/GitLab  ║''${nc}"
    echo -e "''${cyan}╚════════════════════════════════════════╝''${nc}"
    echo ""

    # Check if my repos exist
    if [ ! -d "$github_repo/.git" ] || [ ! -d "$gitlab_repo/.git" ]; then
        echo -e "''${red}✗ Git repositories not found''${nc}"
        echo "Run: cd ~/MyGitStuff && git clone git@github.com:tolgaerok/Nixos-25.11.git"
        echo "     cd ~/MyGitStuff && git clone git@gitlab.com:kingtolga/nixos-25-11-kde-nvidia.git"
        exit 1
    fi

    # sync and show changes
    sync_repo() {
        local repo_path="$1"
        local repo_name="$2"
        local color="$3"

        echo -e "''${color}═══ ''${repo_name} ═══''${nc}"
        cd "$repo_path" || exit 1

        # Copy my files
        ${pkgs.rsync}/bin/rsync -av --delete --exclude='.git' "$source_dir/" "$repo_path/" > /dev/null 2>&1

        # any changes?
        local changes=$(${pkgs.git}/bin/git status --porcelain | wc -l)

        if [ "$changes" -eq 0 ]; then
            echo -e "''${green}✓ No changes detected brother''${nc}"
            echo ""
            return 0
        fi

        echo -e "''${yellow}Changes detected: ''${changes} file(s)''${nc}"
        echo ""

        # Show the changes
        echo -e "''${cyan}Modified files:''${nc}"
        ${pkgs.git}/bin/git status --short | while IFS= read -r line; do
            local status="''${line:0:2}"
            local file="''${line:3}"

            case "$status" in
                "M ") echo -e "  ''${yellow}●''${nc} Modified: $file" ;;
                "A ") echo -e "  ''${green}+''${nc} Added:    $file" ;;
                "D ") echo -e "  ''${red}-''${nc} Deleted:  $file" ;;
                "??") echo -e "  ''${blue}?''${nc} New:      $file" ;;
                *) echo -e "  ''${magenta}~''${nc} Changed:  $file" ;;
            esac
        done

        echo ""
        echo -e "''${cyan}File changes:''${nc}"
        ${pkgs.git}/bin/git diff --stat | head -20
        echo ""

        return 1
    }

    # Sync both of my repos and check for changes
    sync_repo "$github_repo" "GitHub" "$blue"
    github_has_changes=$?

    sync_repo "$gitlab_repo" "GitLab" "$magenta"
    gitlab_has_changes=$?

    # no changes? no prob, exit
    if [ "$github_has_changes" -eq 0 ] && [ "$gitlab_has_changes" -eq 0 ]; then
        echo -e "''${green}✓ All repositories up to date''${nc}"
        exit 0
    fi

    # oi!, whats your commit message gonna be
    echo -e "''${yellow}═══ COMMIT MESSAGE ═══''${nc}"
    echo -n "Enter commit description: "
    read commit_msg

    # timestamp
    timestamp=$(date +"%d-%m-%Y %H:%M")

    # commit message
    full_commit="(ツ)_/¯ ''${commit_msg} -[ ''${timestamp} ]-"

    echo ""
    echo -e "''${cyan}Full commit message:''${nc}"
    echo -e "''${green}''${full_commit}''${nc}"
    echo ""

    # are u sure?
    echo -n "Push changes to both repos? (y/n): "
    read confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "''${red}Aborted''${nc}"
        exit 0
    fi

    echo ""

    # Push to my GitHub
    if [ "$github_has_changes" -eq 1 ]; then
        echo -e "''${blue}═══ Pushing to GitHub ═══''${nc}"
        cd "$github_repo" || exit 1
        ${pkgs.git}/bin/git add .
        ${pkgs.git}/bin/git commit -m "$full_commit"
        ${pkgs.git}/bin/git push
        echo -e "''${green}✓ GitHub updated''${nc}"
        echo ""
    fi

    # Push to my GitLab
    if [ "$gitlab_has_changes" -eq 1 ]; then
        echo -e "''${magenta}═══ Pushing to GitLab ═══''${nc}"
        cd "$gitlab_repo" || exit 1
        ${pkgs.git}/bin/git add .
        ${pkgs.git}/bin/git commit -m "$full_commit"
        ${pkgs.git}/bin/git push
        echo -e "''${green}✓ GitLab updated''${nc}"
        echo ""
    fi

    echo -e "''${cyan}╔════════════════════════════════════════╗''${nc}"
    echo -e "''${cyan}║         BACKUP COMPLETE                ║''${nc}"
    echo -e "''${cyan}╚════════════════════════════════════════╝''${nc}"
  '';
in { environment.systemPackages = [ myGitup ]; }
