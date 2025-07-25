#!/bin/bash
set -e # Exit immediately if a command fails.

# --- Configuration ---
USERNAME="terraform-prov"
ROLENAME="TerraformProv"
TOKEN_NAME="terraform-token"
COMMENT="Service account for Terraform"

# Define all required permissions for Terraform in one variable
PRIVS="Datastore.AllocateSpace Datastore.Audit Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"

# --- Script Logic ---
echo "--- Starting Terraform User Creation Script ---"
echo ""

# 1. Create Proxmox Role
if ! pveum role list | grep -q "$ROLENAME"; then
    echo "Creating Proxmox role '$ROLENAME'..."
    pveum role add "$ROLENAME" -privs "$PRIVS"
    echo "✅ Proxmox role created."
else
    echo "ℹ️ Proxmox role '$ROLENAME' already exists, skipping."
fi
echo ""

# 2. Create Proxmox User
if ! pveum user list | grep -q "$USERNAME@pve"; then
    echo "Creating Proxmox user '$USERNAME@pve'..."
    pveum user add "$USERNAME@pve" --comment "$COMMENT"
    echo "✅ Proxmox user created."
else
    echo "ℹ️ Proxmox user '$USERNAME@pve' already exists, skipping."
fi
echo ""

# 3. Assign Role to User
echo "Assigning role '$ROLENAME' to user '$USERNAME@pve' on path /"
pveum acl modify / -user "$USERNAME@pve" -role "$ROLENAME"
echo "✅ Role assigned."
echo ""

# 4. Create and Display API Token
echo "--- Generating API Token ---"
echo "IMPORTANT: Copy the token ID and SECRET VALUE below and save them securely."
echo "The secret value will not be shown again."
echo ""
pveum user token add "$USERNAME@pve" "$TOKEN_NAME" --privsep=0

echo ""
echo "--- Script Finished Successfully! ---"
