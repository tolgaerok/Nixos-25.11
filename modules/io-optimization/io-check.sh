#!/usr/bin/env bash
#===============================================================================
# script:  io-check.sh
# author:  kingtolga
# date:    8 feb 26
# version: 1.0
# description: nixos i/o + scheduler diagnostic and scx runtime switcher
#              declarative config handled by io-optimization.nix module
# Reversed engineered my fedora scheduler to nix format
#===============================================================================

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
cyan='\033[0;36m'
magenta='\033[0;35m'
nc='\033[0m'

# scx scheduler descriptions
declare -A schedulers=(
    ["rusty"]="general purpose, auto-adapts to workload|mixed workloads, coding + vms|balanced cpu distribution|EXCELLENT for general use"
    ["lavd"]="latency-aware virtual deadline scheduler|interactive work, ide + vms|ultra-responsive desktop, low input lag|BEST for coding while vms run"
    ["bpfland"]="low-latency gaming scheduler|gaming, desktop responsiveness|snappy ui, fast window switching|good for desktop, less optimal for vms"
    ["rustland"]="userspace scheduler, cpu-pinning focus|cpu-intensive tasks, rendering|fine-grained control, numa-aware|overkill for general use"
    ["flash"]="flash scheduling, throughput-focused|batch processing, compilation|faster build times, less interactive|compile-heavy workloads"
    ["cosmos"]="experimental fair scheduler|testing, development|balanced but untested|not recommended for production"
    ["beerland"]="experimental scheduler|testing only|unknown characteristics|not recommended"
    ["p2dq"]="priority-based dual queue|server workloads|predictable latency for services|server-oriented, not desktop"
    ["tickless"]="experimental tickless scheduler|testing only|minimal timer interrupts|experimental, unstable"
)

declare -A sched_order=(
    [1]="lavd"    [2]="rusty"   [3]="bpfland"
    [4]="flash"   [5]="rustland" [6]="cosmos"
    [7]="p2dq"    [8]="beerland" [9]="tickless"
)

# ── helpers ──────────────────────────────────────────────────────────────────

separator() {
    echo -e "${cyan}════════════════════════════════════════════════════════════════${nc}"
}

header() {
    clear
    separator
    echo -e "${cyan}    $1${nc}"
    separator
    echo ""
}

pause() {
    echo ""
    read -rp "press enter to continue..."
}

# ── system checks ────────────────────────────────────────────────────────────

check_io_schedulers() {
    echo -e "${yellow}io schedulers...${nc}"
    local ok=true

    for dev in /sys/block/sd*/queue/scheduler /sys/block/nvme*/queue/scheduler; do
        [[ -e "$dev" ]] || continue
        local disk=$(basename "$(dirname "$(dirname "$dev")")")
        local current=$(grep -o '\[.*\]' "$dev" | tr -d '[]')
        local rotational=$(cat "$(dirname "$dev")/rotational" 2>/dev/null || echo 0)
        local dtype="ssd"
        [[ $rotational -eq 1 ]] && dtype="hdd"
        [[ "$disk" == nvme* ]] && dtype="nvme"

        echo -e "  $disk: ${blue}$current${nc} ($dtype)"
        if [[ "$dtype" != "hdd" && "$current" != "none" ]]; then
            echo -e "    ${red}→ should be 'none' for $dtype${nc}"
            ok=false
        fi
    done

    $ok && echo -e "  ${green}✓ all ssds/nvme set to none${nc}"
    $ok
}

check_readahead() {
    echo -e "${yellow}read-ahead...${nc}"
    local ok=true

    for dev in /dev/sd[a-z] /dev/nvme[0-9]n[0-9]; do
        [[ -b "$dev" ]] || continue
        local disk=$(basename "$dev")
        local rotational=$(cat "/sys/block/$disk/queue/rotational" 2>/dev/null || echo 0)
        [[ "$disk" == sd* && $rotational -eq 1 ]] && continue
        local current_ra=$(($(blockdev --getra "$dev" 2>/dev/null || echo 0) / 2))

        echo -e "  $dev: ${blue}${current_ra} KB${nc}"
        if [[ $current_ra -gt 1024 ]]; then
            echo -e "    ${red}→ should be 512 KB${nc}"
            ok=false
        fi
    done

    $ok && echo -e "  ${green}✓ read-ahead optimal${nc}"
    $ok
}

check_bbr() {
    echo -e "${yellow}tcp optimization...${nc}"
    local ok=true
    local current_cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
    local autogroup=$(sysctl -n kernel.sched_autogroup_enabled 2>/dev/null)

    if [[ "$current_cc" == "bbr" ]]; then
        echo -e "  ${green}✓ bbr enabled${nc}"
    else
        echo -e "  ${yellow}⚠ bbr not enabled${nc} (current: $current_cc)"
        ok=false
    fi

    if [[ "$autogroup" == "1" ]]; then
        echo -e "  ${green}✓ autogroup enabled${nc}"
    else
        echo -e "  ${yellow}⚠ autogroup disabled${nc}"
        ok=false
    fi

    $ok
}

check_scx_service() {
    echo -e "${yellow}scx service...${nc}"
    if systemctl is-active scx-scheduler.service &>/dev/null; then
        local sched=$(get_current_scx)
        echo -e "  ${green}✓ running: scx_${sched}${nc}"
        if systemctl is-enabled scx-scheduler.service &>/dev/null; then
            echo -e "  ${green}✓ enabled on boot${nc}"
        fi
        return 0
    else
        echo -e "  ${yellow}⚠ not running${nc}"
        return 1
    fi
}

check_nixos_config() {
    echo -e "${yellow}nixos module...${nc}"
    if nixos-option tweaks.io-optimization.enable 2>/dev/null | grep -q "true"; then
        echo -e "  ${green}✓ io-optimization module enabled${nc}"
    else
        echo -e "  ${yellow}⚠ module not detected (check configuration.nix)${nc}"
    fi
}

# ── full check ───────────────────────────────────────────────────────────────

run_full_check() {
    header "SYSTEM ANALYSIS (NixOS)"

    local issues=0

    check_io_schedulers || ((issues++)); echo ""
    check_readahead     || ((issues++)); echo ""
    check_bbr           || ((issues++)); echo ""
    check_scx_service   || ((issues++)); echo ""
    check_nixos_config;                  echo ""

    # kernel features
    show_kernel_features

    separator
    if [[ $issues -eq 0 ]]; then
        echo -e "${green}system fully optimized — $issues issues${nc}"
    else
        echo -e "${yellow}$issues area(s) need attention${nc}"
        echo -e "${cyan}fix by editing io-optimization.nix and running:${nc}"
        echo -e "  ${yellow}sudo nixos-rebuild switch${nc}"
    fi
    separator

    return $issues
}

# ── show current config ─────────────────────────────────────────────────────

show_current() {
    header "CURRENT CONFIGURATION"

    echo -e "${yellow}io schedulers:${nc}"
    for dev in /sys/block/sd*/queue/scheduler /sys/block/nvme*/queue/scheduler; do
        [[ -e "$dev" ]] || continue
        local disk=$(basename "$(dirname "$(dirname "$dev")")")
        local current=$(grep -o '\[.*\]' "$dev" | tr -d '[]')
        local rotational=$(cat "$(dirname "$dev")/rotational" 2>/dev/null || echo 0)
        local dtype="ssd"; [[ $rotational -eq 1 ]] && dtype="hdd"; [[ "$disk" == nvme* ]] && dtype="nvme"

        if [[ "$dtype" != "hdd" && "$current" == "none" ]]; then
            echo -e "  $disk: ${green}$current${nc} ($dtype) ✓"
        elif [[ "$dtype" != "hdd" ]]; then
            echo -e "  $disk: ${red}$current${nc} ($dtype) ✗ should be none"
        else
            echo -e "  $disk: ${blue}$current${nc} ($dtype)"
        fi
    done

    echo -e "\n${yellow}read-ahead:${nc}"
    for dev in /dev/sd[a-z] /dev/nvme[0-9]n[0-9]; do
        [[ -b "$dev" ]] || continue
        local ra=$(($(blockdev --getra "$dev" 2>/dev/null || echo 0) / 2))
        echo -e "  $dev: ${blue}${ra} KB${nc}"
    done

    echo -e "\n${yellow}tcp:${nc}"
    echo -e "  congestion : ${blue}$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)${nc}"
    echo -e "  qdisc      : ${blue}$(sysctl -n net.core.default_qdisc 2>/dev/null)${nc}"
    echo -e "  autogroup  : ${blue}$(sysctl -n kernel.sched_autogroup_enabled 2>/dev/null)${nc}"

    echo -e "\n${yellow}scx scheduler:${nc}"
    local current_scx=$(get_current_scx)
    echo -e "  running    : ${green}$current_scx${nc}"
    if systemctl is-enabled scx-scheduler.service &>/dev/null; then
        echo -e "  persistent : ${green}yes (nixos managed)${nc}"
    else
        echo -e "  persistent : ${red}no${nc}"
    fi

    echo ""
    show_kernel_features
}

show_kernel_features() {
    separator
    echo -e "${cyan}   KERNEL FEATURES ($(uname -r))${nc}"
    separator
    echo ""

    # mglru
    if [[ -f /sys/kernel/mm/lru_gen/enabled ]]; then
        echo -e "  mglru      : ${green}$(cat /sys/kernel/mm/lru_gen/enabled)${nc}"
    else
        echo -e "  mglru      : ${red}not found${nc}"
    fi

    # preemption - nixos uses /proc/config.gz or /boot, what a head fuck that was, thanks to the dark web, i found work arounds...
    local kconfig=""
    if [[ -f /proc/config.gz ]]; then
        kconfig=$(zcat /proc/config.gz 2>/dev/null)
    elif [[ -f /boot/config-$(uname -r) ]]; then
        kconfig=$(cat /boot/config-$(uname -r))
    fi

    if [[ -n "$kconfig" ]]; then
        local preempt=$(echo "$kconfig" | grep "CONFIG_PREEMPT" | grep "=y" | head -1)
        case $preempt in
            *VOLUNTARY*) echo -e "  preempt    : ${green}voluntary${nc}" ;;
            *PREEMPT=y*) echo -e "  preempt    : ${green}full preempt${nc}" ;;
            *NONE*)      echo -e "  preempt    : ${yellow}none (server)${nc}" ;;
            *)           echo -e "  preempt    : ${yellow}unknown${nc}" ;;
        esac

        local tick=$(echo "$kconfig" | grep "CONFIG_HZ=" 2>/dev/null | cut -d'=' -f2)
        [[ -n "$tick" ]] && echo -e "  tick rate  : ${blue}${tick}hz${nc}"

        echo "$kconfig" | grep -q "CONFIG_PREEMPT_DYNAMIC=y" && \
            echo -e "  dynamic    : ${green}yes${nc}"
    fi

    # zswap
    if [[ -f /sys/module/zswap/parameters/enabled ]]; then
        local zswap=$(cat /sys/module/zswap/parameters/enabled)
        [[ "$zswap" == "Y" ]] && echo -e "  zswap      : ${green}enabled${nc}" || echo -e "  zswap      : ${red}disabled${nc}"
    fi

    # sched_ext
    if [[ -f /sys/kernel/sched_ext/state ]]; then
        echo -e "  sched_ext  : ${green}$(cat /sys/kernel/sched_ext/state)${nc}"
    fi

    echo ""
}

# ── scx runtime switcher ────────────────────────────────────────────────────

get_current_scx() {
    if [[ -f /sys/kernel/sched_ext/root/ops ]]; then
        local ops=$(cat /sys/kernel/sched_ext/root/ops 2>/dev/null)
        if [[ -n "$ops" ]]; then
            # strip version suffix: rusty_1.0.19_x86_64... → rusty
            echo "${ops%%_[0-9]*}"
            return
        fi
    fi
    local proc=$(ps -eo comm= | grep '^scx_' | head -1 | sed 's/^scx_//')
    echo "${proc:-none}"
}

scx_chooser() {
    header "SCX CPU SCHEDULER (runtime switch)"

    local current=$(get_current_scx)
    echo -e "${yellow}currently running:${nc} ${green}$current${nc}"
    echo -e "${cyan}note:${nc} runtime switch only — edit io-optimization.nix for permanent change\n"
    echo -e "${cyan}available schedulers:${nc}\n"

    for i in {1..9}; do
        local sched="${sched_order[$i]}"
        local info="${schedulers[$sched]}"
        IFS='|' read -r desc _ _ _ <<< "$info"

        if [[ "$sched" == "$current" ]]; then
            echo -e "  ${green}[$i] $sched${nc} ${yellow}(active)${nc} - $desc"
        else
            echo -e "  ${blue}[$i] $sched${nc} - $desc"
        fi
    done

    echo ""
    echo -e "  ${yellow}[d]${nc} detailed info for a scheduler"
    echo -e "  ${yellow}[q]${nc} back to main menu"
    echo ""
    echo -ne "${blue}choice: ${nc}"
    read -r choice

    case $choice in
        [1-9])
            local sched="${sched_order[$choice]}"
            switch_scx_runtime "$sched"
            pause
            ;;
        d|D)
            show_scx_detail
            pause
            ;;
        q|Q) return ;;
        *)
            echo -e "${red}invalid choice${nc}"
            sleep 1
            ;;
    esac
}

switch_scx_runtime() {
    local sched=$1
    local bin="scx_${sched}"

    # check if binary exists in nix store as this causes conflicts like shoving 2 pine-apples up the arse at the same time
    if ! command -v "$bin" &>/dev/null && ! nix-store -qR /run/current-system 2>/dev/null | xargs -I{} find {} -name "$bin" 2>/dev/null | grep -q .; then
        echo -e "\n${red}scx_${sched} not found in system${nc}"
        echo -e "${yellow}add to configuration.nix:${nc}"
        echo -e "  environment.systemPackages = [ pkgs.scx.${sched} ];"
        echo -e "${yellow}then run:${nc} sudo nixos-rebuild switch"
        return 1
    fi

    echo -e "\n${yellow}switching to scx_${sched} (runtime only)...${nc}"

    # stop current sservice
    if systemctl is-active scx-scheduler.service &>/dev/null; then
        sudo systemctl stop scx-scheduler.service
        echo -e "${green}✓ stopped current scheduler${nc}"
    fi

    # kill any stray scx processes as nixos and linux in general sucks goat balls
    pkill -f "scx_" 2>/dev/null
    sleep 1

    # start the new one directly (temporary, won't survive reboot) as i need to test
    local bin_path=$(command -v "$bin" 2>/dev/null)
    if [[ -z "$bin_path" ]]; then
        bin_path=$(nix-store -qR /run/current-system 2>/dev/null | xargs -I{} find {} -name "$bin" -executable 2>/dev/null | head -1)
    fi

    if [[ -n "$bin_path" ]]; then
        sudo "$bin_path" &
        disown
        sleep 2

        if pgrep -f "scx_${sched}" &>/dev/null; then
            echo -e "${green}✓ scx_${sched} running (runtime only, not persistent)${nc}"
            echo -e "${cyan}for permanent:${nc} set tweaks.io-optimization.scx.scheduler = \"${sched}\";"
        else
            echo -e "${red}✗ failed to start scx_${sched}${nc}"
        fi
    else
        echo -e "${red}✗ could not find scx_${sched} binary${nc}"
    fi
}

show_scx_detail() {
    echo -ne "\n${blue}scheduler number (1-9): ${nc}"
    read -r num

    if [[ ! "$num" =~ ^[1-9]$ ]]; then
        echo -e "${red}invalid number${nc}"
        return
    fi

    local sched="${sched_order[$num]}"
    local info="${schedulers[$sched]}"
    IFS='|' read -r desc use_case benefits rec <<< "$info"

    echo ""
    separator
    echo -e "${cyan}    $sched${nc}"
    separator
    echo -e "  ${cyan}description:${nc}    $desc"
    echo -e "  ${yellow}best for:${nc}       $use_case"
    echo -e "  ${green}benefits:${nc}       $benefits"
    echo -e "  ${magenta}recommendation:${nc} $rec"
    separator
}

# ── main menu ────────────────────────────────────────────────────────────────

show_main_menu() {
    header "LINUXTWEAKS I/O + SCHEDULER MANAGER (NixOS)"

    echo -e "  ${blue}[1]${nc} full system check"
    echo -e "  ${blue}[2]${nc} scx cpu scheduler switcher (runtime)"
    echo -e "  ${blue}[3]${nc} show current configuration"
    echo -e "  ${blue}[q]${nc} exit"
    echo ""
    echo -ne "${blue}choice: ${nc}"
}

main() {
    while true; do
        show_main_menu
        read -r choice

        case $choice in
            1) run_full_check; pause ;;
            2) scx_chooser ;;
            3) show_current; pause ;;
            q|Q)
                echo ""
                echo -e "${green}current scx:${nc} $(get_current_scx)"
                echo ""
                echo -e "${cyan}remember:${nc} all persistent config lives in io-optimization.nix"
                echo -e "  ${yellow}sudo nixos-rebuild switch${nc} to apply changes"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${red}invalid choice${nc}"
                sleep 1
                ;;
        esac
    done
}

main

# this configuration caused brain damage, need pot and whisky to recover from the nose bleeds