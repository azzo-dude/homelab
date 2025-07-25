#!/bin/bash
set -e # Exit immediately if a command fails.

# Load variables and functions from their separate files
source ./setup.conf
source ./functions.sh

#==================================================
# Main Execution Logic
#==================================================
main() {
    echo "==================================================="
    echo " Proxmox User Setup Script"
    echo "==================================================="
    echo ""
    
    setup_console_user
    setup_terraform_user
    generate_terraform_token

    echo "=========================================="
    echo "      Production Setup Complete!"
    echo "=========================================="
}

# --- Execute the Script ---
main
