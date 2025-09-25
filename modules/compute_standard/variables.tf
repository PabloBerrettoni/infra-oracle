variable "availability_domain" {
  type = string
}

variable "compartment_id" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "hostname_label" {
  type = string
}

variable "ssh_public_keys" {
  type = list(object({
    publickey = string
  }))
}