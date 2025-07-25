#!/bin/bash
set -e # Exit immediately if a command fails.

# --- Configuration ---
USERNAME="user-pve"
ROLENAME="ConsoleUser"
PRIVS="VM.Console,Sys.Console"
COMMENT="User for console access and file management"

# --- Script Logic ---
echo "--- Starting User Creation Script ---"
echo ""

# 1. Create System User (this part is interactive)
if ! id "$USERNAME" &>/dev/null; then
    echo "Creating system user '$USERNAME'..."
    adduser "$USERNAME"
    echo "✅ System user created."
else
    echo "ℹ️ System user '$USERNAME' already exists, skipping."
fi
echo ""

# 2. Create Proxmox Role
if ! pveum role list | grep -q "$ROLENAME"; then
    echo "Creating Proxmox role '$ROLENAME' with privileges: $PRIVS"
    pveum role add "$ROLENAME" -privs "$PRIVS"
    echo "✅ Proxmox role created."
else
    echo "ℹ️ Proxmox role '$ROLENAME' already exists, skipping."
fi
echo ""

# 3. Create Proxmox User
if ! pveum user list | grep -q "$USERNAME@pve"; then
    echo "Creating Proxmox user '$USERNAME@pve'..."
    pveum user add "$USERNAME@pve" --comment "$COMMENT"
    echo "✅ Proxmox user created."
else
    echo "ℹ️ Proxmox user '$USERNAME@pve' already exists, skipping."
fi
echo ""

# 4. Assign Role to User
echo "Assigning role '$ROLENAME' to user '$USERNAME@pve' on path /"
pveum acl modify / -user "$USERNAME@pve" -role "$ROLENAME"
echo "✅ Role assigned."
echo ""

# --- Finish ---
echo "--- Script Finished Successfully! ---"
