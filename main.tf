# main.tf

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://127.0.0.1:8006/api2/json" // Use localhost IP since you're on the server
  pm_api_token_id     = "terraform-user@pve!terraform-token"
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}

# --- ADD THIS RESOURCE BLOCK ---
resource "proxmox_vm_qemu" "example_vm" {
  # --- General Settings ---
  name        = "my-first-terraform-vm"
  desc        = "Created with Terraform"
  target_node = "pve" // IMPORTANT: Change to your Proxmox node's name

  # --- Template and OS ---
  clone = "ubuntu-2204-cloudinit-template" // IMPORTANT: Change to your template name
  agent = 1                                // Enable the QEMU guest agent
  
  # --- Hardware ---
  cores  = 1
  memory = 1024

  # --- Networking ---
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # --- Storage ---
  disk {
    storage = "local-lvm" // IMPORTANT: Change to your storage pool name
    size    = "10G"
    type    = "scsi"
  }
}
