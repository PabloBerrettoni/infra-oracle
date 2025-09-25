output "nameservers" {
  value       = oci_dns_zone.portfolio_zone.nameservers
  description = "OCI nameservers for DNS delegation"
}

output "zone_id" {
  value       = oci_dns_zone.portfolio_zone.id
  description = "ID of the DNS zone"
}