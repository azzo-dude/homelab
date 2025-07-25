#!/bin/bash
set -e # Exit immediately if a command fails.

# Load variables from the configuration file
source ./setup.conf

# --- Helper Functions ---

# Creates a Proxmox role if it does not already exist.
# $1: Role Name
# $2: Privileges (comma-separated string)
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

# Creates a Proxmox PVE user if it does not already exist.
# $1: Username (without @pve)
# $2: Comment
create_pve_user() {
    local username="$1@pve"
    local comment=$2
    if ! pveum user list | grep -q "$username"; then
        echo "Creating Proxmox user '$username'..."
        pveum user add "$username" --comment "$comment"
        echo "✅ Proxmox user created."
        return 0 # Return success (user was created)
    else
        echo "ℹ️ Proxmox user '$username' already exists, skipping."
        return 1 # Return failure (user already existed)
    fi
}

# Assigns a role to a PVE user.
# $1: Username (without @pve)
# $2: Role Name
assign_pve_role() {
    local username="$1@pve"
    local rolename=$2
    echo "Assigning role '$rolename' to user '$username'..."
    pveum acl modify / -user "$username" -role "$rolename"
    echo "✅ Role assigned."
}

# --- Main Logic Functions ---

setup_console_user() {
    echo "--- Setting up Console User ($CONSOLE_USERNAME) ---"
    create_pve_role "$CONSOLE_ROLENAME" "$CONSOLE_PRIVS"
    # The 'if' statement ensures we only ask for a password when the user is newly created.
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
    create_pve_user "$TERRAFORM_USERNAME" "$TERRAFORM_COMMENT" > /dev/null # Suppress output as no password is needed
    assign_pve_role "$TERRAFORM_USERNAME" "$TERRAFORM_ROLENAME"
    echo ""
}

generate_terraform_token() {
    echo "--- Generating Terraform API Token ---"
    echo "IMPORTANT: Copy the token ID and SECRET VALUE below and save them securely."
    echo "The secret value will not be shown again."
    echo ""
    pveum user token add "$TERRAFORM_USERNAME@pve" "$TERRAFORM_TOKEN_NAME" --privsep=0
    echo ""
}

# --- Script Execution ---

main() {
    echo "=========================================="
    echo " Proxmox Initial User Setup Script"
    echo "=========================================="
    echo ""
    
    setup_console_user
    setup_terraform_user
    generate_terraform_token

    echo "=========================================="
    echo "      Initial Setup Complete!"
    echo "=========================================="
}

# Run the main function
main
