#!/usr/bin/env bash
# nvidia-info.sh
# my simple NVIDIA driver info display
# Tolga Erok - Jan 2026

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}           ${BOLD}NVIDIA Driver Information${NC}                    ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if nvidia driver is loaded
if ! lsmod | grep -q nvidia; then
	echo -e "${RED}✗ NVIDIA driver not loaded${NC}"
	exit 1
fi

# driver type (open vs proprietary)
echo -e "${BOLD}Driver Type:${NC}"
if cat /proc/driver/nvidia/version 2>/dev/null | grep -q "Open Kernel Module"; then
	echo -e "  ${GREEN}✓ Open Source Driver${NC}"
	DRIVER_TYPE="open"
else
	echo -e "  ${YELLOW}⚠ Proprietary Driver${NC}"
	DRIVER_TYPE="proprietary"
fi
echo ""

# Driver version
echo -e "${BOLD}Driver Version:${NC}"
VERSION=$(cat /proc/driver/nvidia/version 2>/dev/null | grep "NVRM version" | awk '{print $8}')
echo -e "  ${CYAN}$VERSION${NC}"
echo ""

# GPU Info
echo -e "${BOLD}GPU Information:${NC}"
if command -v nvidia-smi &>/dev/null; then
	GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
	GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | head -1)
	GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1)
	GPU_POWER=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader 2>/dev/null | head -1)

	echo -e "  Model:       ${GREEN}$GPU_NAME${NC}"
	echo -e "  Temperature: ${YELLOW}${GPU_TEMP}°C${NC}"
	echo -e "  Memory:      ${CYAN}$GPU_MEM${NC}"
	echo -e "  Power:       ${BLUE}$GPU_POWER${NC}"
else
	echo -e "  ${RED}nvidia-smi not available${NC}"
fi
echo ""

# Kernel & Module info
echo -e "${BOLD}Kernel & Modules:${NC}"
KERNEL=$(uname -r)
echo -e "  Kernel:      ${CYAN}$KERNEL${NC}"

# Check loaded modules
MODULES=$(lsmod | grep nvidia | awk '{print $1}' | sort | tr '\n' ' ')
echo -e "  Modules:     ${GREEN}$MODULES${NC}"
echo ""

# Power Management Status
echo -e "${BOLD}Power Management:${NC}"
if [ -f /proc/driver/nvidia/gpus/*/power ]; then
	PM_STATUS=$(cat /proc/driver/nvidia/gpus/*/power | grep "Runtime D3 status" | awk -F: '{print $2}' | xargs)
	if [[ "$PM_STATUS" == "N/A" ]] || [[ "$PM_STATUS" == "Disabled" ]]; then
		echo -e "  ${GREEN}✓ Disabled (Correct for desktop)${NC}"
	else
		echo -e "  ${YELLOW}⚠ Enabled: $PM_STATUS${NC}"
	fi
else
	echo -e "  ${YELLOW}Status file not found${NC}"
fi
echo ""

# GSP Firmware (Open driver indicator)
echo -e "${BOLD}GSP Firmware:${NC}"
if modinfo nvidia 2>/dev/null | grep -q "gsp_"; then
	echo -e "  ${GREEN}✓ Loaded (Open driver feature)${NC}"
else
	echo -e "  ${YELLOW}⚠ Not detected${NC}"
fi
echo ""

# OpenGL Info
echo -e "${BOLD}OpenGL Renderer:${NC}"
if command -v glxinfo &>/dev/null; then
	RENDERER=$(glxinfo 2>/dev/null | grep "OpenGL renderer" | cut -d: -f2 | xargs)
	GL_VERSION=$(glxinfo 2>/dev/null | grep "OpenGL version" | cut -d: -f2 | xargs)
	echo -e "  Renderer:    ${GREEN}$RENDERER${NC}"
	echo -e "  GL Version:  ${CYAN}$GL_VERSION${NC}"
else
	echo -e "  ${YELLOW}glxinfo not available (install mesa-utils)${NC}"
fi
echo ""

# Nix Store Path
echo -e "${BOLD}Nix Package:${NC}"
NIX_PATH=$(nix-store -q --references /run/booted-system/kernel-modules 2>/dev/null | grep nvidia)
if [[ $NIX_PATH == *"nvidia-open"* ]]; then
	echo -e "  ${GREEN}✓ nvidia-open package${NC}"
elif [[ $NIX_PATH == *"nvidia"* ]]; then
	echo -e "  ${YELLOW}⚠ nvidia (proprietary) package${NC}"
fi
echo -e "  Path: ${BLUE}$(basename $NIX_PATH)${NC}"
echo ""

# Config Status
echo -e "${BOLD}Configuration:${NC}"
if [ -f /etc/nixos/modules/nvidia/default.nix ]; then
	OPEN_SETTING=$(grep "open =" /etc/nixos/modules/nvidia/default.nix | head -1 | awk '{print $3}' | tr -d ';')
	PM_SETTING=$(grep "powerManagement.enable =" /etc/nixos/modules/nvidia/default.nix | head -1 | awk '{print $3}' | tr -d ';')

	echo -e "  open = ${GREEN}$OPEN_SETTING${NC}"
	echo -e "  powerManagement.enable = ${GREEN}$PM_SETTING${NC}"
else
	echo -e "  ${YELLOW}Config file not found${NC}"
fi
echo ""

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                        ${BOLD}Summary${NC}                           ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"

if [[ "$DRIVER_TYPE" == "open" ]]; then
	echo -e "${GREEN}✓ Running NVIDIA Open Source Driver${NC}"
	echo -e "${GREEN}✓ Optimal configuration for GTX 1650${NC}"
else
	echo -e "${YELLOW}⚠ Running Proprietary Driver${NC}"
	echo -e "${YELLOW}⚠ Consider switching to open driver (open = true)${NC}"
fi
echo ""
