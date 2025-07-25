#!/bin/bash
set -e # Exit immediately if a command fails.

# Load variables from the configuration file
source ./setup.conf

# --- Script Logic ---
echo "==================================================="
echo " Proxmox User Setup Script (DRY RUN / TEST MODE)"
echo "==================================================="
echo "This script will only show the commands to be executed."
echo ""

# --- 1. Console User ---
echo "--- [TEST] Console User ($CONSOLE_USERNAME) ---"
if ! id "$CONSOLE_USERNAME" &>/dev/null; then
    echo "Would create system user: 'adduser $CONSOLE_USERNAME'"
else
    echo "ℹ️ System user '$CONSOLE_USERNAME' already exists, skipping."
fi

if ! pveum role list | grep -q "$CONSOLE_ROLENAME"; then
    echo "Would create role: 'pveum role add $CONSOLE_ROLENAME -privs \"$CONSOLE_PRIVS\"'"
else
    echo "ℹ️ Proxmox role '$CONSOLE_ROLENAME' already exists, skipping."
fi

if ! pveum user list | grep -q "$CONSOLE_USERNAME@pve"; then
    echo "Would create user: 'pveum user add $CONSOLE_USERNAME@pve --comment \"$CONSOLE_COMMENT\"'"
else
    echo "ℹ️ Proxmox user '$CONSOLE_USERNAME@pve' already exists, skipping."
fi

echo "Would assign role: 'pveum acl modify / -user $CONSOLE_USERNAME@pve -role $CONSOLE_ROLENAME'"
echo ""

# --- 2. Terraform User ---
echo "--- [TEST] Terraform User ($TERRAFORM_USERNAME) ---"
if ! pveum role list | grep -q "$TERRAFORM_ROLENAME"; then
    echo "Would create role: 'pveum role add $TERRAFORM_ROLENAME -privs \"$TERRAFORM_PRIVS\"'"
else
    echo "ℹ️ Proxmox role '$TERRAFORM_ROLENAME' already exists, skipping."
fi

if ! pveum user list | grep -q "$TERRAFORM_USERNAME@pve"; then
    echo "Would create user: 'pveum user add $TERRAFORM_USERNAME@pve --comment \"$TERRAFORM_COMMENT\"'"
else
    echo "ℹ️ Proxmox user '$TERRAFORM_USERNAME@pve' already exists, skipping."
fi

echo "Would assign role: 'pveum acl modify / -user $TERRAFORM_USERNAME@pve -role $TERRAFORM_ROLENAME'"
echo ""

# --- 3. Terraform API Token ---
echo "--- [TEST] Terraform API Token ---"
echo "Would generate token: 'pveum user token add $TERRAFORM_USERNAME@pve $TERRAFORM_TOKEN_NAME --privsep=0'"
echo ""

echo "=========================================="
echo "           Dry Run Complete!"
echo "=========================================="
