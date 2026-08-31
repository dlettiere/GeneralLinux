#!/usr/bin/env bash
# ==============================================================================
# Mount Device by UUID via /etc/fstab
# Repository: https://github.com/dlettiere/GeneralLinux
# ==============================================================================
# Usage:
#   sudo ./mount_by_uuid.sh <device> <mount_point> [mount_options]
#
# Examples:
#   sudo ./mount_by_uuid.sh /dev/sda1 /mnt/data
#   sudo ./mount_by_uuid.sh /dev/nvme0n1p1 /mnt/storage "defaults,nofail"
# ==============================================================================

set -euo pipefail

# --- UI / Logging Helpers ---
info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

# 1. Require root privileges
if [[ "${EUID}" -ne 0 ]]; then
    error "This script must be run as root (use sudo)."
fi

# 2. Validate argument count
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <device> <mount_point> [mount_options]" >&2
    echo "Example: $0 /dev/sda1 /mnt/data defaults,nofail" >&2
    exit 1
fi

DEVICE="$1"
MOUNT_POINT="$2"
OPTIONS="${3:-defaults}"
DUMP="0"
PASS="2"

# 3. Validate device
if [[ ! -b "${DEVICE}" ]]; then
    error "Device '${DEVICE}' is not a valid block device."
fi

# 4. Extract UUID and Filesystem type
UUID="$(blkid -s UUID -o value "${DEVICE}" || true)"
FSTYPE="$(blkid -s TYPE -o value "${DEVICE}" || true)"

if [[ -z "${UUID}" ]]; then
    error "Could not determine UUID for '${DEVICE}'. Ensure the partition is formatted."
fi

if [[ -z "${FSTYPE}" ]]; then
    error "Could not detect filesystem type for '${DEVICE}'."
fi

# Certain filesystems (like btrfs, xfs, swap) don't use fsck pass checks
if [[ "${FSTYPE}" == "btrfs" || "${FSTYPE}" == "xfs" || "${FSTYPE}" == "swap" ]]; then
    PASS="0"
fi

info "Target Device:     ${DEVICE}"
info "UUID:              ${UUID}"
info "Filesystem:        ${FSTYPE}"
info "Mount Point:       ${MOUNT_POINT}"
info "Mount Options:     ${OPTIONS}"

# 5. Check if UUID or mount point is already in /etc/fstab
if grep -qE "UUID=${UUID}" /etc/fstab; then
    warn "An entry for UUID=${UUID} already exists in /etc/fstab:"
    grep -E "UUID=${UUID}" /etc/fstab
    error "Aborting to prevent duplicate entries."
fi

if grep -qE "[[:space:]]${MOUNT_POINT}[[:space:]]" /etc/fstab; then
    warn "Mount point '${MOUNT_POINT}' is already defined in /etc/fstab:"
    grep -E "[[:space:]]${MOUNT_POINT}[[:space:]]" /etc/fstab
    error "Aborting to avoid conflicting mount points."
fi

# 6. Create mount directory if it doesn't exist
if [[ ! -d "${MOUNT_POINT}" ]]; then
    info "Creating mount point directory: ${MOUNT_POINT}"
    mkdir -p "${MOUNT_POINT}"
fi

# 7. Backup /etc/fstab
BACKUP_FILE="/etc/fstab.bak.$(date +%Y%m%d_%H%M%S)"
info "Backing up /etc/fstab to ${BACKUP_FILE}"
cp /etc/fstab "${BACKUP_FILE}"

# 8. Append entry to /etc/fstab
FSTAB_LINE="UUID=${UUID}    ${MOUNT_POINT}    ${FSTYPE}    ${OPTIONS}    ${DUMP}  ${PASS}"
info "Adding entry to /etc/fstab:"
echo "    ${FSTAB_LINE}"
echo -e "\n# Added by mount_by_uuid on $(date)\n${FSTAB_LINE}" >> /etc/fstab

# 9. Test mount
info "Mounting filesystems from /etc/fstab..."
if mount -a; then
    if mountpoint -q "${MOUNT_POINT}"; then
        success "Device '${DEVICE}' (UUID=${UUID}) mounted successfully at '${MOUNT_POINT}'."
    else
        warn "'mount -a' succeeded, but '${MOUNT_POINT}' does not appear to be an active mountpoint."
    fi
else
    warn "'mount -a' failed! Restoring original /etc/fstab..."
    cp "${BACKUP_FILE}" /etc/fstab
    error "Mount verification failed. /etc/fstab was restored to its previous state."
fi
