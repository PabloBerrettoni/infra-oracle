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

variable "docker_image" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "subdomain" {
  type = string
}

variable "domains" {
  type        = list(string)
  description = "List of domains for nginx server_name"
}

variable "email" {
  type = string
}