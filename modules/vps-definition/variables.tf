# modules/vps-definition/variables.tf

variable "compartment_id" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "instance_name" {
  description = "Name for the VPS instance"
  type        = string
  default     = "my-vps"
}

variable "hostname_label" {
  description = "Hostname label for the instance"
  type        = string
  default     = "myvps"
}

variable "ssh_public_keys" {
  description = "List of SSH public keys for accessing the instance"
  type = list(object({
    user      = string
    publickey = string
  }))
}

variable "ocpus" {
  description = "Number of OCPUs for the instance (half of Always Free: 2 out of 4)"
  type        = number
  default     = 2
  
  validation {
    condition     = var.ocpus >= 1 && var.ocpus <= 4
    error_message = "OCPUs must be between 1 and 4 for Always Free tier."
  }
}

variable "memory_in_gbs" {
  description = "Amount of memory in GB (half of Always Free: 12 out of 24)"
  type        = number
  default     = 12
  
  validation {
    condition     = var.memory_in_gbs >= 6 && var.memory_in_gbs <= 24
    error_message = "Memory must be between 6 and 24 GB for Always Free tier."
  }
}