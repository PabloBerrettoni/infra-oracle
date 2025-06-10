# projects/prod/outputs.tf

output "tenancy_name" {
  description = "Name of the tenancy - confirms connection is working"
  value       = data.oci_identity_tenancy.current.name
}

# VPS outputs from the module
output "vps_public_ip" {
  description = "Public IP address of the VPS"
  value       = module.web_vps.instance_public_ip
}

output "vps_private_ip" {
  description = "Private IP address of the VPS"
  value       = module.web_vps.instance_private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the VPS"
  value       = module.web_vps.ssh_connection_command
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${module.web_vps.instance_public_ip}"
}