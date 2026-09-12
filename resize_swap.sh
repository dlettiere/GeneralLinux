#!/usr/bin/env bash
# ==============================================================================
# Configure / Resize Swapfile and Swappiness
# Repository: https://github.com/dlettiere/GeneralLinux
# ==============================================================================
# Usage:
#   sudo ./resize_swap.sh
# ==============================================================================

set -euo pipefail

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script requires superuser privileges. Elevating with sudo..."
    exec sudo bash "$0" "$@"
fi

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}       Swap & Swappiness Configuration    ${NC}"
echo -e "${BLUE}==========================================${NC}"

# Detect current swapfile
SWAP_FILE=$(awk '$2 == "file" {print $1; exit}' /proc/swaps 2>/dev/null || true)
if [ -z "$SWAP_FILE" ]; then
    SWAP_FILE="/swap.img"
    echo -e "${YELLOW}[!] No active swapfile detected in /proc/swaps. Defaulting to: $SWAP_FILE${NC}"
else
    echo -e "${GREEN}[*] Detected active swapfile: $SWAP_FILE${NC}"
fi

# Gather current stats
CURRENT_SWAPPINESS=$(cat /proc/sys/vm/swappiness 2>/dev/null || echo "60")
MEM_AVAILABLE_KB=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
SWAP_USED_KB=$(awk '/SwapTotal/ {total=$2} /SwapFree/ {free=$2} END {print total-free}' /proc/meminfo)

MEM_AVAILABLE_HUMAN=$(awk "BEGIN {printf \"%.2f GiB\", $MEM_AVAILABLE_KB/1048576}")
SWAP_USED_HUMAN=$(awk "BEGIN {printf \"%.2f GiB\", $SWAP_USED_KB/1048576}")

echo ""
echo -e "Current Status:"
free -h
echo ""
echo -e "Current vm.swappiness : ${YELLOW}${CURRENT_SWAPPINESS}${NC}"
echo -e "Available RAM         : ${GREEN}${MEM_AVAILABLE_HUMAN}${NC}"
echo -e "Currently in Swap     : ${YELLOW}${SWAP_USED_HUMAN}${NC}"
echo ""

# Safety check: swapoff will migrate used swap back into RAM
if [ "$SWAP_USED_KB" -ge "$MEM_AVAILABLE_KB" ]; then
    echo -e "${RED}[ERROR] Currently used swap ($SWAP_USED_HUMAN) exceeds or is dangerously close to available RAM ($MEM_AVAILABLE_HUMAN).${NC}"
    echo -e "${RED}Turning off swap right now could trigger Out-Of-Memory (OOM) killer!${NC}"
    echo "Please close memory-intensive applications before continuing."
    exit 1
fi

# 1. Prompt for new swap size
DEFAULT_SIZE="8G"
while true; do
    read -rp "Enter new swap size (e.g., 8G, 16G, 4G) [default: ${DEFAULT_SIZE}]: " INPUT_SIZE
    NEW_SIZE="${INPUT_SIZE:-$DEFAULT_SIZE}"
    NEW_SIZE=$(echo "$NEW_SIZE" | tr '[:lower:]' '[:upper:]')

    if [[ "$NEW_SIZE" =~ ^[0-9]+[GM]$ ]]; then
        break
    else
        echo -e "${RED}Invalid size format. Please enter a number followed by G or M (e.g. 8G or 8192M).${NC}"
    fi
done

# Check available disk space on target filesystem
TARGET_DIR=$(dirname "$SWAP_FILE")
FREE_DISK_KB=$(df -k "$TARGET_DIR" | awk 'NR==2 {print $4}')

# Approximate requested size in KB
SIZE_UNIT="${NEW_SIZE: -1}"
SIZE_NUM="${NEW_SIZE:0:-1}"
if [ "$SIZE_UNIT" = "G" ]; then
    REQ_SIZE_KB=$((SIZE_NUM * 1024 * 1024))
else
    REQ_SIZE_KB=$((SIZE_NUM * 1024))
fi

if [ "$REQ_SIZE_KB" -gt "$FREE_DISK_KB" ]; then
    echo -e "${RED}[ERROR] Insufficient disk space on $(df -h "$TARGET_DIR" | awk 'NR==2 {print $6}')!${NC}"
    echo -e "Requested: $NEW_SIZE, Available: $(df -h "$TARGET_DIR" | awk 'NR==2 {print $4}')"
    exit 1
fi

# 2. Prompt for swappiness
DEFAULT_SWAPPINESS="20"
while true; do
    read -rp "Enter new vm.swappiness (0-100, recommended: 10-20) [default: ${DEFAULT_SWAPPINESS}]: " INPUT_SWAPPINESS
    NEW_SWAPPINESS="${INPUT_SWAPPINESS:-$DEFAULT_SWAPPINESS}"

    if [[ "$NEW_SWAPPINESS" =~ ^[0-9]+$ ]] && [ "$NEW_SWAPPINESS" -ge 0 ] && [ "$NEW_SWAPPINESS" -le 100 ]; then
        break
    else
        echo -e "${RED}Invalid swappiness. Must be an integer between 0 and 100.${NC}"
    fi
done

echo ""
echo -e "${BLUE}Planned Changes:${NC}"
echo -e "  Swap file path   : $SWAP_FILE"
echo -e "  New Swap size    : ${GREEN}$NEW_SIZE${NC}"
echo -e "  New Swappiness   : ${GREEN}$NEW_SWAPPINESS${NC} (persisted in /etc/sysctl.d/99-swappiness.conf)"
echo ""

read -rp "Proceed with these changes? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted by user."
    exit 0
fi

echo ""
# Turn off swap
if grep -q "$SWAP_FILE" /proc/swaps; then
    echo -e "${YELLOW}[1/5] Deactivating swap ($SWAP_FILE)... this may take a moment while moving data to RAM...${NC}"
    swapoff "$SWAP_FILE"
else
    echo -e "${YELLOW}[1/5] Swap is not active on $SWAP_FILE, skipping swapoff.${NC}"
fi

# Allocate new size
echo -e "${YELLOW}[2/5] Allocating $NEW_SIZE for $SWAP_FILE...${NC}"
# Delete previous file if exists to ensure clean allocation
rm -f "$SWAP_FILE"
if ! fallocate -l "$NEW_SIZE" "$SWAP_FILE" 2>/dev/null; then
    echo -e "${YELLOW}[!] fallocate failed, falling back to dd...${NC}"
    if [ "$SIZE_UNIT" = "G" ]; then
        dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$((SIZE_NUM * 1024)) status=progress
    else
        dd if=/dev/zero of="$SWAP_FILE" bs=1M count="$SIZE_NUM" status=progress
    fi
fi

# Set permissions
echo -e "${YELLOW}[3/5] Setting secure permissions (chmod 600)...${NC}"
chmod 600 "$SWAP_FILE"

# Format swap
echo -e "${YELLOW}[4/5] Formatting $SWAP_FILE as swap...${NC}"
mkswap "$SWAP_FILE"

# Enable swap
echo -e "${YELLOW}[5/5] Activating new swap...${NC}"
swapon "$SWAP_FILE"

# Verify fstab persistence
if ! grep -qs "$SWAP_FILE" /etc/fstab; then
    echo -e "${YELLOW}[*] Adding $SWAP_FILE to /etc/fstab for boot persistence...${NC}"
    echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
fi

# Apply & persist swappiness
echo -e "${YELLOW}[*] Applying and persisting vm.swappiness = $NEW_SWAPPINESS...${NC}"
sysctl -w "vm.swappiness=$NEW_SWAPPINESS" >/dev/null
echo "vm.swappiness=$NEW_SWAPPINESS" > /etc/sysctl.d/99-swappiness.conf

echo ""
echo -e "${GREEN}✓ Successfully updated swap and swappiness!${NC}"
echo ""
echo -e "New Memory & Swap Status:"
free -h
echo ""
echo -e "Active vm.swappiness: ${GREEN}$(cat /proc/sys/vm/swappiness)${NC}"
