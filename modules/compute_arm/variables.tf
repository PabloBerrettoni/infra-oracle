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
  description = "OCI image OCID to use. Pinned to a specific image to avoid drift-forced replacement."
  type        = string
  default     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaarh3eggnbg7hpf75v7xjlw6tasjrbftucxkynb2zhxu4g342uooba"
}