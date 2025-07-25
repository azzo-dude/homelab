#!/bin/bash

#==================================================
# Function Definitions (Prototypes)
#==================================================

# --- High-Level Functions ---
setup_console_user() {
    echo "--- Setting up Console User ($CONSOLE_USERNAME) ---"
    create_pve_role "$CONSOLE_ROLENAME" "$CONSOLE_PRIVS"
    if create_pve_user "$CONSOLE_USERNAME" "$CONSOLE_COMMENT"; then
        echo "Setting password for new user $CONSOLE_USERNAME@pve (this is interactive)..."
        pveum user passwd "$CONSOLE_USERNAME@pve"
    fi
    assign_pve_role "$CONSOLE_USERNAME" "$CONSOLE_ROLENAME"
    echo ""
}

setup_terraform_user() {
    echo "--- Setting up Terraform User ($TERRAFORM_USERNAME) ---"
    create_pve_role "$TERRAFORM_ROLENAME" "$TERRAFORM_PRIVS"
    create_pve_user "$TERRAFORM_USERNAME" "$TERRAFORM_COMMENT" > /dev/null
    assign_pve_role "$TERRAFORM_USERNAME" "$TERRAFORM_ROLENAME"
    echo ""
}

generate_terraform_token() {
    echo "--- Generating Terraform API Token ---"
    echo "IMPORTANT: Copy the token ID and SECRET VALUE below and save them securely."
    echo ""
    pveum user token add "$TERRAFORM_USERNAME@pve" "$TERRAFORM_TOKEN_NAME" --privsep=0
    echo ""
}

# --- Helper Functions ---
create_pve_role() {
    local rolename=$1
    local privs=$2
    if ! pveum role list | grep -q "$rolename"; then
        echo "Creating Proxmox role '$rolename'..."
        pveum role add "$rolename" -privs "$privs"
        echo "✅ Proxmox role created."
    else
        echo "ℹ️ Proxmox role '$rolename' already exists, skipping."
    fi
}

create_pve_user() {
    local username="$1@pve"
    local comment=$2
    if ! pveum user list | grep -q "$username"; then
        echo "Creating Proxmox user '$username'..."
        pveum user add "$username" --comment "$comment"
        echo "✅ Proxmox user created."
        return 0
    else
        echo "ℹ️ Proxmox user '$username' already exists, skipping."
        return 1
    fi
}

assign_pve_role() {
    local username="$1@pve"
    local rolename=$2
    echo "Assigning role '$rolename' to user '$username'..."
    pveum acl modify / -user "$username" -role "$rolename"
    echo "✅ Role assigned."
}
