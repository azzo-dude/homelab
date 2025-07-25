#!/bin/bash

#==================================================
# Function Definitions (DRY RUN / TEST MODE)
#==================================================

# --- High-Level Functions ---
setup_console_user() {
    echo "--- [TEST] Setting up Console User ($CONSOLE_USERNAME) ---"
    create_pve_role "$CONSOLE_ROLENAME" "$CONSOLE_PRIVS"
    if create_pve_user "$CONSOLE_USERNAME" "$CONSOLE_COMMENT"; then
        echo "[TEST] Would set password for new user $CONSOLE_USERNAME@pve with command:"
        echo "       pveum user passwd \"$CONSOLE_USERNAME@pve\""
    fi
    assign_pve_role "$CONSOLE_USERNAME" "$CONSOLE_ROLENAME"
    echo ""
}

setup_terraform_user() {
    echo "--- [TEST] Setting up Terraform User ($TERRAFORM_USERNAME) ---"
    create_pve_role "$TERRAFORM_ROLENAME" "$TERRAFORM_PRIVS"
    create_pve_user "$TERRAFORM_USERNAME" "$TERRAFORM_COMMENT" > /dev/null
    assign_pve_role "$TERRAFORM_USERNAME" "$TERRAFORM_ROLENAME"
    echo ""
}

generate_terraform_token() {
    echo "--- [TEST] Generating Terraform API Token ---"
    echo "[TEST] Would generate token with command:"
    echo "       pveum user token add \"$TERRAFORM_USERNAME@pve\" \"$TERRAFORM_TOKEN_NAME\" --privsep=0"
    echo ""
}

# --- Helper Functions ---
create_pve_role() {
    local rolename=$1
    local privs=$2
    if ! pveum role list | grep -q "$rolename"; then
        echo "[TEST] Would create Proxmox role '$rolename' with command:"
        echo "       pveum role add \"$rolename\" -privs \"$privs\""
    else
        echo "ℹ️  Proxmox role '$rolename' already exists, would skip."
    fi
}

create_pve_user() {
    local username="$1@pve"
    local comment=$2
    if ! pveum user list | grep -q "$username"; then
        echo "[TEST] Would create Proxmox user '$username' with command:"
        echo "       pveum user add \"$username\" --comment \"$comment\""
        return 0
    else
        echo "ℹ️  Proxmox user '$username' already exists, would skip."
        return 1
    fi
}

assign_pve_role() {
    local username="$1@pve"
    local rolename=$2
    echo "[TEST] Would assign role '$rolename' to user '$username' with command:"
    echo "       pveum acl modify / -user \"$username\" -role \"$rolename\""
}
