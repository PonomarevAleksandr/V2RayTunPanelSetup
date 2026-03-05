#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# V2RayTun Panel Setup — Universal Installer
# ═══════════════════════════════════════════════════════════════════════════════
# 
# One-liner installation:
#   bash <(curl -fsSL https://raw.githubusercontent.com/PonomarevAleksandr/V2RayTunPanelSetup/main/install.sh)
#
# For private repo with token:
#   GITHUB_TOKEN=your_token bash <(curl -fsSL ...)
#
# ═══════════════════════════════════════════════════════════════════════════════

set -e

VERSION="1.0.0"

GITHUB_REPO="${V2RAYTUNPANEL_REPO:-PonomarevAleksandr/v2raytunpanel}"
GITHUB_BRANCH="${V2RAYTUNPANEL_BRANCH:-main}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
SETUP_DIR="/opt/v2raytunpanel-setup"

GIT_URL="https://github.com/$GITHUB_REPO.git"
[ -n "$GITHUB_TOKEN" ] && GIT_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/$GITHUB_REPO.git"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

print_banner() {
  clear
  echo ""
  echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${RESET}"
  echo -e ""
  echo -e "  ${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "  ${CYAN}║                                                                           ║${RESET}"
  echo -e "  ${CYAN}║  ${YELLOW}██╗   ██╗██████╗ ██████╗  █████╗ ██╗   ██╗████████╗██╗   ██╗███╗   ██╗ ${CYAN}║${RESET}"
  echo -e "  ${CYAN}║  ${YELLOW}╚██╗ ██╔╝╚════██╗██╔══██╗██╔══██╗╚██╗ ██╔╝╚══██╔══╝██║   ██║████╗  ██║ ${CYAN}║${RESET}"
  echo -e "  ${CYAN}║  ${YELLOW} ╚████╔╝  █████╔╝██████╔╝███████║ ╚████╔╝    ██║   ██║   ██║██╔██╗ ██║ ${CYAN}║${RESET}"
  echo -e "  ${CYAN}║  ${YELLOW}  ╚██╔╝  ██╔═══╝ ██╔══██╗██╔══██║  ╚██╔╝     ██║   ██║   ██║██║╚██╗██║ ${CYAN}║${RESET}"
  echo -e "  ${CYAN}║  ${YELLOW}   ██║   ███████╗██║  ██║██║  ██║   ██║      ██║   ╚██████╔╝██║ ╚████║ ${CYAN}║${RESET}"
  echo -e "  ${CYAN}║  ${YELLOW}   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝      ╚═╝    ╚═════╝ ╚═╝  ╚═══╝ ${CYAN}║${RESET}"
  echo -e "  ${CYAN}║                          ${GREEN}P A N E L   S E T U P${CYAN}                          ║${RESET}"
  echo -e "  ${CYAN}║                                                                           ║${RESET}"
  echo -e "  ${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${RESET}"
  echo -e ""
  echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${RESET}"
  echo -e "${GREEN}V2RayTun Panel Setup${RESET} — ${CYAN}Universal Installer v${VERSION}${RESET}"
  echo -e "${YELLOW}https://github.com/PonomarevAleksandr/v2raytunpanel${RESET}"
  echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${RESET}"
  echo ""
}

info() { echo -e "${CYAN}[INFO]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${RESET} $1"; }

detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
    OS_NAME=$PRETTY_NAME
  elif [ -f /etc/redhat-release ]; then
    OS="centos"
    OS_NAME=$(cat /etc/redhat-release)
  elif [ -f /etc/debian_version ]; then
    OS="debian"
    OS_NAME="Debian $(cat /etc/debian_version)"
  else
    OS="unknown"
    OS_NAME="Unknown"
  fi
  echo "$OS"
}

detect_package_manager() {
  if command -v apt-get &> /dev/null; then
    echo "apt"
  elif command -v dnf &> /dev/null; then
    echo "dnf"
  elif command -v yum &> /dev/null; then
    echo "yum"
  elif command -v apk &> /dev/null; then
    echo "apk"
  elif command -v pacman &> /dev/null; then
    echo "pacman"
  elif command -v zypper &> /dev/null; then
    echo "zypper"
  else
    echo "unknown"
  fi
}

install_package() {
  local package="$1"
  local pm=$(detect_package_manager)
  
  info "Installing $package..."
  
  case "$pm" in
    apt)
      apt-get update -y >/dev/null 2>&1
      apt-get install -y "$package" >/dev/null 2>&1
      ;;
    dnf)
      dnf install -y "$package" >/dev/null 2>&1
      ;;
    yum)
      yum install -y "$package" >/dev/null 2>&1
      ;;
    apk)
      apk add --no-cache "$package" >/dev/null 2>&1
      ;;
    pacman)
      pacman -Sy --noconfirm "$package" >/dev/null 2>&1
      ;;
    zypper)
      zypper install -y "$package" >/dev/null 2>&1
      ;;
    *)
      error "Unsupported package manager. Install $package manually."
      return 1
      ;;
  esac
}

install_docker() {
  if command -v docker &> /dev/null; then
    success "Docker is already installed"
    return 0
  fi
  
  info "Installing Docker..."
  
  local os=$(detect_os)
  
  case "$os" in
    ubuntu|debian|raspbian|linuxmint|pop)
      curl -fsSL https://get.docker.com | sh
      ;;
    centos|rhel|fedora|rocky|almalinux|ol)
      curl -fsSL https://get.docker.com | sh
      ;;
    alpine)
      apk add --no-cache docker docker-compose
      rc-update add docker boot 2>/dev/null || true
      service docker start 2>/dev/null || true
      ;;
    arch|manjaro|endeavouros)
      pacman -Sy --noconfirm docker docker-compose
      ;;
    opensuse*|sles)
      zypper install -y docker docker-compose
      ;;
    *)
      warn "Attempting generic Docker install..."
      curl -fsSL https://get.docker.com | sh || {
        error "Docker installation failed. Install manually: https://docs.docker.com/engine/install/"
        return 1
      }
      ;;
  esac
  
  if command -v systemctl &> /dev/null; then
    systemctl enable docker 2>/dev/null || true
    systemctl start docker 2>/dev/null || true
  fi
  
  if command -v docker &> /dev/null; then
    success "Docker installed successfully"
  else
    error "Docker installation failed"
    return 1
  fi
}

check_docker_compose() {
  if docker compose version &> /dev/null; then
    return 0
  fi
  
  info "Installing Docker Compose plugin..."
  
  local pm=$(detect_package_manager)
  
  case "$pm" in
    apt)
      apt-get update -y >/dev/null 2>&1
      apt-get install -y docker-compose-plugin >/dev/null 2>&1 || true
      ;;
    dnf|yum)
      dnf install -y docker-compose-plugin 2>/dev/null || yum install -y docker-compose-plugin 2>/dev/null || true
      ;;
  esac
  
  if ! docker compose version &> /dev/null; then
    info "Downloading Docker Compose..."
    mkdir -p /usr/local/lib/docker/cli-plugins
    COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)"
    curl -SL "$COMPOSE_URL" -o /usr/local/lib/docker/cli-plugins/docker-compose 2>/dev/null
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  fi
  
  if docker compose version &> /dev/null; then
    success "Docker Compose is ready"
  else
    error "Docker Compose installation failed"
    return 1
  fi
}

download_setup() {
  info "Downloading V2RayTun Setup scripts..."
  
  rm -rf "$SETUP_DIR"
  mkdir -p "$SETUP_DIR"
  cd "$SETUP_DIR"
  
  local DOWNLOAD_SUCCESS=false
  
  git init -q 2>/dev/null || true
  git remote add origin "$GIT_URL" 2>/dev/null || true
  git config core.sparseCheckout true 2>/dev/null || true
  echo "scripts/setup" > .git/info/sparse-checkout 2>/dev/null || true
  
  if git fetch --depth 1 origin "$GITHUB_BRANCH" -q 2>/dev/null; then
    if git checkout FETCH_HEAD 2>/dev/null; then
      if [ -f "scripts/setup/v2raytunsetup.sh" ]; then
        DOWNLOAD_SUCCESS=true
        success "Downloaded via sparse checkout"
      fi
    fi
  fi
  
  if [ "$DOWNLOAD_SUCCESS" = false ]; then
    warn "Sparse checkout failed, trying full clone..."
    rm -rf "$SETUP_DIR"/*
    rm -rf "$SETUP_DIR/.git"
    
    if git clone --depth 1 --single-branch -b "$GITHUB_BRANCH" "$GIT_URL" repo-tmp 2>/dev/null; then
      if [ -d "repo-tmp/scripts/setup" ]; then
        mkdir -p scripts
        mv repo-tmp/scripts/setup scripts/
        rm -rf repo-tmp
        DOWNLOAD_SUCCESS=true
        success "Downloaded via full clone"
      fi
    fi
  fi
  
  if [ "$DOWNLOAD_SUCCESS" = false ]; then
    warn "Git failed, trying archive download..."
    
    ARCHIVE_URL="https://github.com/$GITHUB_REPO/archive/refs/heads/$GITHUB_BRANCH.zip"
    if [ -n "$GITHUB_TOKEN" ]; then
      curl -fsSL -H "Authorization: token $GITHUB_TOKEN" "$ARCHIVE_URL" -o archive.zip 2>/dev/null
    else
      curl -fsSL "$ARCHIVE_URL" -o archive.zip 2>/dev/null
    fi
    
    if [ -f "archive.zip" ] && [ -s "archive.zip" ]; then
      unzip -q archive.zip 2>/dev/null || true
      EXTRACTED_DIR=$(ls -d */ 2>/dev/null | head -1)
      if [ -n "$EXTRACTED_DIR" ] && [ -d "${EXTRACTED_DIR}scripts/setup" ]; then
        mkdir -p scripts
        mv "${EXTRACTED_DIR}scripts/setup" scripts/
        rm -rf "$EXTRACTED_DIR" archive.zip
        DOWNLOAD_SUCCESS=true
        success "Downloaded via archive"
      fi
    fi
  fi
  
  if [ "$DOWNLOAD_SUCCESS" = false ]; then
    echo ""
    error "Failed to download setup scripts"
    echo ""
    echo -e "${YELLOW}Possible reasons:${RESET}"
    echo "  • Repository is private (provide GITHUB_TOKEN)"
    echo "  • Network connection issues"
    echo "  • Repository or branch doesn't exist"
    echo ""
    echo -e "${CYAN}Try with token:${RESET}"
    echo "  GITHUB_TOKEN=your_token bash <(curl -fsSL ...)"
    echo ""
    exit 1
  fi
  
  chmod +x scripts/setup/*.sh 2>/dev/null || true
  chmod +x scripts/setup/*/*.sh 2>/dev/null || true
  chmod +x scripts/setup/common/*.sh 2>/dev/null || true
}

main() {
  print_banner
  
  if [ "$(id -u)" != "0" ]; then
    error "This script must be run as root"
    echo ""
    echo "Run: sudo bash install.sh"
    echo "Or:  sudo bash <(curl -fsSL ...)"
    exit 1
  fi
  
  OS=$(detect_os)
  PM=$(detect_package_manager)
  
  echo -e "${CYAN}System Info:${RESET}"
  echo -e "  OS:              ${GREEN}${OS_NAME:-$OS}${RESET}"
  echo -e "  Package Manager: ${GREEN}$PM${RESET}"
  echo -e "  Architecture:    ${GREEN}$(uname -m)${RESET}"
  echo ""
  
  if ! command -v curl &> /dev/null; then
    install_package curl
  fi
  
  if ! command -v git &> /dev/null; then
    install_package git
  fi
  
  if ! command -v unzip &> /dev/null; then
    install_package unzip
  fi
  
  install_docker
  check_docker_compose
  
  download_setup
  
  echo ""
  success "Setup ready! Launching installer..."
  echo ""
  
  exec bash "$SETUP_DIR/scripts/setup/v2raytunsetup.sh"
}

main "$@"
