# projects/prod/outputs.tf

output "tenancy_name" {
  description = "Name of the tenancy - confirms connection is working"
  value       = data.oci_identity_tenancy.current.name
}

# VPS outputs from the compute_standard module
output "vps_public_ip" {
  description = "Public IP address of the VPS"
  value       = module.compute_standard.public_ip
}

output "vps_private_ip" {
  description = "Private IP address of the VPS"
  value       = module.compute_standard.private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the VPS"
  value       = "ssh ubuntu@${module.compute_standard.public_ip}"
}

output "website_url" {
  description = "URL to access the website"
  value       = "https://pabloberrettoni.com"
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = module.network.subnet_id
}

output "vcn_id" {
  description = "ID of the VCN"
  value       = module.network.vcn_id
}