#!/bin/bash
# ============================================================
#  AMD NPU Auto-Installer — Krackan / Strix Point (aie2p)
#  Target : Ubuntu 26.04 LTS | SRE Optimized (Source in src/)
#  Logic  : Direct Deployment + Compatibility Layer (Dummy)
# ============================================================

# 1. Safety and Environment Initialization
set -euo pipefail
cd "$(dirname "$0")"

# 2. Configuration & Colors
SRC_DIR="src"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[•]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
die()     { echo -e "${RED}[✗]${RESET} $*" >&2; exit 1; }

REQUIRED_FILES=(
    "$SRC_DIR/xrt_202610.2.23.0_26.04-amd64-base.tar.gz"
    "$SRC_DIR/xrt_202610.2.23.0_26.04-amd64-npu.tar.gz"
    "$SRC_DIR/xrt_plugin.2.23.0_26.04-amd64-amdxdna.deb"
)

# ── Helper Functions ────────────────────────────────────────

create_compatibility_layer() {
    info "Creating Compatibility Layer (xrt-base-dummy)..."
    local DUMMY_DIR="/tmp/xrt-base-dummy"
    mkdir -p "$DUMMY_DIR/DEBIAN"
    cat <<DUMMY_EOF > "$DUMMY_DIR/DEBIAN/control"
Package: xrt-base
Version: 2.23.0
Section: misc
Priority: optional
Architecture: amd64
Maintainer: SRE-Admin
Description: Dummy package to satisfy XRT dependencies on Ubuntu 26.04
DUMMY_EOF
    dpkg-deb --build "$DUMMY_DIR" "/tmp/xrt-base-2.23.0_amd64.deb" > /dev/null
    sudo dpkg -i "/tmp/xrt-base-2.23.0_amd64.deb"
    rm -rf "$DUMMY_DIR" "/tmp/xrt-base-2.23.0_amd64.deb"
}

deploy_archive() {
  local ARCHIVE=$1
  info "Deploying contents of $ARCHIVE to system root..."
  sudo tar -xf "$ARCHIVE" -C /
}

# ── Main Process ────────────────────────────────────────────

clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "   AMD NPU Krackan — Automated Deployment (Zen 5)"
echo -e "${CYAN}============================================================${RESET}\n"

[ -d "$SRC_DIR" ] || die "Directory '$SRC_DIR' not found. Ensure archives are in $SRC_DIR/"
for f in "${REQUIRED_FILES[@]}"; do
    [ -f "$f" ] || die "Missing file: $f"
done

info "Installing build tools and DKMS..."
sudo apt-get update -qq
sudo apt-get install -y dkms cmake gcc g++ libboost-all-dev libdrm-dev \
    ocl-icd-opencl-dev opencl-headers uuid-dev libssl-dev > /dev/null
success "Build tools ready."

create_compatibility_bridge() {
    create_compatibility_layer
}
create_compatibility_bridge
success "APT dependency bridge created."

deploy_archive "${REQUIRED_FILES[0]}"
deploy_archive "${REQUIRED_FILES[1]}"
success "XRT binaries deployed to /opt/xilinx/xrt/"

info "Installing XDNA Plugin (DKMS)..."
sudo dpkg -i "${REQUIRED_FILES[2]}" > /dev/null || sudo apt-get install -f -y
success "Plugin installed."

info "Configuring system environment (udev & limits)..."
[ -f /etc/udev/rules.d/99-amdxdna.rules ] || \
    echo 'KERNEL=="accel*",DRIVERS=="amdxdna",MODE="0666"' | sudo tee /etc/udev/rules.d/99-amdxdna.rules > /dev/null

LIMITS_FILE="/etc/security/limits.d/99-amdxdna.conf"
if [ ! -f "$LIMITS_FILE" ]; then
    echo -e "* soft memlock unlimited\n* hard memlock unlimited" | sudo tee "$LIMITS_FILE" > /dev/null
fi
success "Permissions and memory limits updated."

info "Updating shell profiles..."
SETUP_CMD="source /opt/xilinx/xrt/setup.sh > /dev/null 2>&1"
for RC in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$RC" ] && ! grep -q "xilinx/xrt/setup.sh" "$RC"; then
        echo "$SETUP_CMD" >> "$RC"
        info "Updated $RC"
    fi
done

echo -e "\n${GREEN}============================================================${RESET}"
success "SUCCESS\! AMD NPU is fully integrated."
echo -e "Please REBOOT to apply kernel changes and memory limits."
echo -e "${GREEN}============================================================${RESET}\n"
