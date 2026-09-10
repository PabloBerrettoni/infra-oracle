variable "compartment_id" {
  type = string
}

variable "network_name" {
  description = "Name prefix for the VCN, IGW, route table, security list and subnet."
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN (unique within the region)."
  type        = string
  default     = "mainvcn"
}

variable "subnet_dns_label" {
  description = "DNS label for the public subnet (unique within the VCN)."
  type        = string
  default     = "public"
}

variable "allowed_tcp_ports" {
  description = "TCP ingress ports opened to the internet (0.0.0.0/0) on the default security list."
  type        = list(number)
  default     = [22, 80, 443, 8000, 8443, 25565]
}

variable "allowed_udp_ports" {
  description = "UDP ingress ports opened to the internet (0.0.0.0/0) on the default security list."
  type        = list(number)
  default     = [1194]
}
