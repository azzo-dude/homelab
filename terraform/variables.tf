variable "proxmox_api_token_secret" {
  description = "The secret for the Proxmox API token, read from the environment."
  type        = string
  sensitive   = true
}
