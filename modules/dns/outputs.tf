output "nameservers" {
  value       = oci_dns_zone.zone.nameservers
  description = "OCI nameservers for DNS delegation"
}

output "zone_id" {
  value       = oci_dns_zone.zone.id
  description = "ID of the DNS zone"
}