variable "compartment_id" {
  description = "Compartment where the DNS zone lives."
  type        = string
}

variable "zone_name" {
  description = "DNS zone name to manage (e.g. \"example.com\"). The zone must be registered and delegated to OCI nameservers (or it will be created by this module)."
  type        = string
}

variable "ttl" {
  description = "TTL in seconds for the A records."
  type        = number
  default     = 300
}

variable "records" {
  description = "A records to create in the zone. 'name' is the label relative to the zone (use \"\" for the apex), 'ip' is the target IPv4 address."
  type = list(object({
    name = string
    ip   = string
  }))
}
