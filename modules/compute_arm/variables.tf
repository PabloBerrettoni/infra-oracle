variable "compartment_id" {
  type = string
}

variable "instance_name" {
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

variable "ocpus" {
  type = number
}

variable "memory_in_gbs" {
  type = number
}

variable "subnet_id" {
  type = string
}

variable "image_ocid" {
  description = "OCI image OCID to use. Pinned to a specific image to avoid drift-forced replacement. Region-specific - override with an image OCID from your home region."
  type        = string
  default     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaarh3eggnbg7hpf75v7xjlw6tasjrbftucxkynb2zhxu4g342uooba"
}

variable "domain" {
  description = "FQDN that fronts the Crafty web UI (nginx server_name + Let's Encrypt cert). Needs an A record pointing at this instance's public IP."
  type        = string
}

variable "email" {
  description = "Email used to register the Let's Encrypt certificate."
  type        = string
}

variable "timezone" {
  description = "IANA timezone passed to the containers (e.g. \"Europe/Madrid\")."
  type        = string
  default     = "UTC"
}

variable "crafty_http_port" {
  description = "Port for the Crafty web UI over HTTP."
  type        = number
  default     = 8000
}

variable "crafty_https_port" {
  description = "Port for the Crafty web UI over HTTPS."
  type        = number
  default     = 8443
}

variable "minecraft_port" {
  description = "Port for the Minecraft server itself."
  type        = number
  default     = 25565
}