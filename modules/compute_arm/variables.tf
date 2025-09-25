variable "availability_domain" {
  type = string
}
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
variable "domain" {
  type        = string
  description = "Domain name for Let’s Encrypt (e.g., pabloberrettoni.com)"
}
variable "email" {
  type        = string
  description = "Email for Let’s Encrypt notifications"
}