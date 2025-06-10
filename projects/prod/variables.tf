# projects/prod/variables.tf (cleaned for public repo)

variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the public key"
  type        = string
}

variable "private_key" {
  description = "Content of the private key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
  default     = ""
}

variable "region" {
  description = "OCI region"
  type        = string
  default     = "us-ashburn-1"
}

# SSH keys
variable "ssh_public_keys" {
  description = "List of SSH public keys for accessing instances"
  type = list(object({
    user      = string
    publickey = string
  }))
  default = [
    {
      user      = "your-username"
      publickey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-public-key-here"
    }
  ]
}