terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://127.0.0.1:8006/api2/json"
  pm_api_token_id     = "terraform-user@pve!terraform-token"
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}

# --- LXC Master Node ---
resource "proxmox_lxc" "lxc_master" {
  hostname    = "LXC-MASTER"
  vmid        = 100
  target_node = "pve" // IMPORTANT: Change to your Proxmox node's name

  // --- Template & Storage ---
  ostemplate = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst" // IMPORTANT: Change to your container template
  rootfs {
    storage = "local-lvm" // IMPORTANT: Change to your storage pool
    size    = "8G"
  }

  // --- Resources ---
  memory = 1024
  cores  = 1

  // --- Options ---
  start        = true // Start on boot
  unprivileged = true
  features {
    keyctl = true
  }

  // --- Networking ---
  // Ensure your template is configured for DHCP or set a static IP.
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

  // --- Automation: Update on create ---
  // This requires the container to have SSH enabled and a known user/password.
  // Ensure your template has an SSH server and a user (e.g., 'root').
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "sleep 15", // Give the container time to boot and get an IP
      "apt-get update",
      "apt-get upgrade -y"
    ]

    connection {
      type     = "ssh"
      user     = "root"
      password = "YOUR_TEMPLATE_ROOT_PASSWORD" // IMPORTANT: Change this!
      host     = self.ssh_host
    }
  }
}

# --- LXC Network Node ---
resource "proxmox_lxc" "lxc_network" {
  hostname    = "LXC-NETWORK"
  vmid        = 101
  target_node = "pve" // IMPORTANT: Change to your Proxmox node's name

  // --- Template & Storage ---
  ostemplate = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst" // IMPORTANT: Change to your container template
  rootfs {
    storage = "local-lvm" // IMPORTANT: Change to your storage pool
    size    = "8G"
  }

  // --- Resources ---
  memory = 1024
  cores  = 1

  // --- Options ---
  start        = true // Start on boot
  unprivileged = true
  features {
    keyctl = true
  }

  // --- Networking ---
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

  // --- Automation: Update on create ---
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "sleep 15",
      "apt-get update",
      "apt-get upgrade -y"
    ]

    connection {
      type     = "ssh"
      user     = "root"
      password = "YOUR_TEMPLATE_ROOT_PASSWORD" // IMPORTANT: Change this!
      host     = self.ssh_host
    }
  }
}
