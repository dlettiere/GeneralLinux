#!/usr/bin/env bash
# ==============================================================================
# General Linux Setup Script
# Repository: https://github.com/dlettiere/GeneralLinux
# ==============================================================================

set -euo pipefail

# --- Configuration ---
REPO_RAW_URL="https://raw.githubusercontent.com/dlettiere/GeneralLinux/refs/heads/main"
BASE_PACKAGES=(
    tmux
    btop
    htop
    nmap
    tilde
    qdirstat
    rdiff-backup
    rsync
    git
    vnstat
    tldr
    curl
)

# --- UI / Logging Helpers ---
info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

prompt_yn() {
    local prompt_msg="$1"
    local default="${2:-n}"
    local answer

    if [[ "${AUTO_YES:-false}" == "true" ]]; then
        return 0
    fi

    if [[ "$default" == "y" ]]; then
        prompt_msg="$prompt_msg [Y/n]: "
    else
        prompt_msg="$prompt_msg [y/N]: "
    fi

    read -r -n 1 -p "$prompt_msg" answer < /dev/tty || true
    echo ""

    # Default value fallback if user presses Enter
    if [[ -z "$answer" ]]; then
        answer="$default"
    fi

    [[ "$answer" =~ ^[Yy]$ ]]
}

download_file() {
    local url="$1"
    local dest="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$dest" "$url"
    else
        error "Neither curl nor wget is installed. Please install one to continue."
    fi
}

# --- Tasks ---

setup_aliases() {
    info "Setting up bash aliases..."

    # Backup existing aliases if found
    if [[ -f "$HOME/.bash_aliases" ]]; then
        local backup="$HOME/.bash_aliases.bak.$(date +%Y%m%d%H%M%S)"
        warn "Existing ~/.bash_aliases found. Backing up to $backup"
        cp "$HOME/.bash_aliases" "$backup"
    fi

    # Fetch updated .bash_aliases from repository
    download_file "${REPO_RAW_URL}/.bash_aliases" "$HOME/.bash_aliases"

    # Ensure local override file exists
    if [[ ! -f "$HOME/.bash_aliases_local" ]]; then
        touch "$HOME/.bash_aliases_local"
    fi

    success "Configured ~/.bash_aliases and ~/.bash_aliases_local"
}

install_base_packages() {
    if ! command -v apt-get >/dev/null 2>&1; then
        warn "apt-get package manager not found. Skipping apt packages."
        return 0
    fi

    echo ""
    info "Base packages to install:"
    echo "  ${BASE_PACKAGES[*]}"
    echo ""

    if prompt_yn "Install base packages?" "y"; then
        info "Updating package lists..."
        sudo apt-get update -y

        info "Installing base packages..."
        sudo apt-get install -y "${BASE_PACKAGES[@]}"
        success "Base packages installed successfully."
    else
        info "Skipped base packages."
    fi
}

install_nordvpn() {
    echo ""
    if prompt_yn "Install NordVPN?" "n"; then
        info "Installing NordVPN..."
        if command -v curl >/dev/null 2>&1; then
            sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
        else
            sh <(wget -qO- https://downloads.nordcdn.com/apps/linux/install.sh)
        fi

        if getent group nordvpn >/dev/null 2>&1; then
            sudo usermod -aG nordvpn "$USER"
            info "Added $USER to nordvpn group."
        fi
        success "NordVPN installed successfully."
    else
        info "Skipped NordVPN installation."
    fi
}

install_tailscale() {
    echo ""
    if prompt_yn "Install Tailscale?" "n"; then
        info "Installing Tailscale..."
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL https://tailscale.com/install.sh | sh
        else
            wget -qO- https://tailscale.com/install.sh | sh
        fi
        success "Tailscale installed successfully."
    else
        info "Skipped Tailscale installation."
    fi
}

show_help() {
    cat <<EOF
Usage: ./setup.sh [OPTIONS]

Options:
  -y, --yes     Automatically answer yes to all installation prompts
  -h, --help    Display this help message and exit

Online execution:
  bash <(curl -fsSL ${REPO_RAW_URL}/setup.sh)
EOF
}

# --- Main Entrypoint ---

main() {
    export AUTO_YES="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y|--yes)
                AUTO_YES="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                warn "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo "========================================"
    echo "       General Linux Environment Setup   "
    echo "========================================"

    setup_aliases
    install_base_packages
    install_nordvpn
    install_tailscale

    echo ""
    success "Setup complete! Run 'source ~/.bashrc' or restart your terminal to apply changes."
}

main "$@"
