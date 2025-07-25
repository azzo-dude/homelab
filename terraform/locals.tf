# --- GLOBAL VARIABLES (LOCALS) ---

locals {
  # --- Proxmox API Credentials ---
  # WARNING: Hardcoding secrets is a security risk!
  api_token_id     = "terraform-user@pve!terraform-token"
  api_token_secret = "YOUR_API_SECRET_HERE" // IMPORTANT: Change this!

  # --- LXC Container Settings ---
  target_node      = "pve"
  template_storage = "local"
  template_name    = "vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  disk_storage     = "local-lvm"
  root_password    = "YOUR_TEMPLATE_ROOT_PASSWORD" // IMPORTANT: Change this!

  # --- Hostnames ---
  master_hostname  = "LXC-MASTER"
  network_hostname = "LXC-NETWORK"
}
