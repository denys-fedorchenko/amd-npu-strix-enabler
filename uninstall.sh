#!/bin/bash
# ============================================================
#  AMD NPU Uninstaller — Clean System Rollback
#  Target : Ubuntu 24.04 / 26.04 LTS
# ============================================================

# 1. Safety and Environment Initialization
set -euo pipefail
cd "$(dirname "$0")" 

# 2. Colors for output
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'
info()    { echo -e "${YELLOW}[•]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }

echo -e "${RED}============================================================${RESET}"
echo -e "   AMD NPU — Automated Cleanup Process"
echo -e "${RED}============================================================${RESET}\n"

# 3. Package Removal
info "Removing XDNA Plugin and XRT Compatibility Layer..."
sudo apt-get purge -y xrt-plugin-amdxdna xrt-base || info "Packages already removed or not found."
sudo apt-get autoremove -y > /dev/null

# 4. Filesystem Cleanup
info "Cleaning up XRT directories in /opt/..."
if [ -d "/opt/xilinx/xrt" ]; then
    sudo rm -rf /opt/xilinx/xrt
    success "Directories removed successfully."
else
    info "/opt/xilinx/xrt not found, skipping."
fi

# 5. Configuration Removal
info "Removing system configuration files..."
sudo rm -f /etc/udev/rules.d/99-amdxdna.rules
sudo rm -f /etc/security/limits.d/99-amdxdna.conf
sudo rm -f /etc/OpenCL/vendors/xilinx.icd
success "System configs cleaned."

# 6. Shell Profile Cleanup
info "Cleaning up shell profiles (.bashrc, .zshrc, .profile)..."
for RC in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$RC" ]; then
        sed -i '/xilinx\/xrt\/setup.sh/d' "$RC"
        info "Profile cleaned: $RC"
    fi
done

echo -e "\n${GREEN}============================================================${RESET}"
success "CLEANUP COMPLETE\! Your system is now back to its original state."
echo -e "${GREEN}============================================================${RESET}\n"
