#!/bin/bash
set -e # Exit immediately if a command fails.

# Load variables from the configuration file
source ./setup.conf


# --- Script Logic ---
echo "=========================================="
echo " Proxmox Initial User Setup Script"
echo "=========================================="
echo ""

# --- 1. Set up Console User ---
echo "--- Setting up Console User ($CONSOLE_USERNAME) ---"

# System User (interactive password prompt)
if ! id "$CONSOLE_USERNAME" &>/dev/null; then
    echo "Creating system user '$CONSOLE_USERNAME'..."
    adduser "$CONSOLE_USERNAME"
    echo "✅ System user created."
else
    echo "ℹ️ System user '$CONSOLE_USERNAME' already exists, skipping."
fi

# Proxmox Role for Console User
if ! pveum role list | grep -q "$CONSOLE_ROLENAME"; then
    echo "Creating Proxmox role '$CONSOLE_ROLENAME'..."
    pveum role add "$CONSOLE_ROLENAME" -privs "$CONSOLE_PRIVS"
    echo "✅ Proxmox role created."
else
    echo "ℹ️ Proxmox role '$CONSOLE_ROLENAME' already exists, skipping."
fi

# Proxmox User for Console User
if ! pveum user list | grep -q "$CONSOLE_USERNAME@pve"; then
    echo "Creating Proxmox user '$CONSOLE_USERNAME@pve'..."
    pveum user add "$CONSOLE_USERNAME@pve" --comment "$CONSOLE_COMMENT"
    echo "✅ Proxmox user created."
else
    echo "ℹ️ Proxmox user '$CONSOLE_USERNAME@pve' already exists, skipping."
fi

# Assign Console Role
echo "Assigning role '$CONSOLE_ROLENAME' to user '$CONSOLE_USERNAME@pve'..."
pveum acl modify / -user "$CONSOLE_USERNAME@pve" -role "$CONSOLE_ROLENAME"
echo "✅ Role assigned for console user."
echo ""


# --- 2. Set up Terraform User ---
echo "--- Setting up Terraform User ($TERRAFORM_USERNAME) ---"

# Proxmox Role for Terraform
if ! pveum role list | grep -q "$TERRAFORM_ROLENAME"; then
    echo "Creating Proxmox role '$TERRAFORM_ROLENAME'..."
    pveum role add "$TERRAFORM_ROLENAME" -privs "$TERRAFORM_PRIVS"
    echo "✅ Proxmox role created."
else
    echo "ℹ️ Proxmox role '$TERRAFORM_ROLENAME' already exists, skipping."
fi

# Proxmox User for Terraform
if ! pveum user list | grep -q "$TERRAFORM_USERNAME@pve"; then
    echo "Creating Proxmox user '$TERRAFORM_USERNAME@pve'..."
    pveum user add "$TERRAFORM_USERNAME@pve" --comment "$TERRAFORM_COMMENT"
    echo "✅ Proxmox user created."
else
    echo "ℹ️ Proxmox user '$TERRAFORM_USERNAME@pve' already exists, skipping."
fi

# Assign Terraform Role
echo "Assigning role '$TERRAFORM_ROLENAME' to user '$TERRAFORM_USERNAME@pve'..."
pveum acl modify / -user "$TERRAFORM_USERNAME@pve" -role "$TERRAFORM_ROLENAME"
echo "✅ Role assigned for Terraform user."
echo ""


# --- 3. Generate Terraform API Token ---
echo "--- Generating Terraform API Token ---"
echo "IMPORTANT: Copy the token ID and SECRET VALUE below and save them securely."
echo "The secret value will not be shown again."
echo ""
pveum user token add "$TERRAFORM_USERNAME@pve" "$TERRAFORM_TOKEN_NAME" --privsep=0
echo ""

echo "=========================================="
echo "      Initial Setup Complete!"
echo "=========================================="
