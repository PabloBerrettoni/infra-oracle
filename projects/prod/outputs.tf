# projects/prod/outputs.tf

output "tenancy_name" {
  description = "Name of the tenancy - confirms connection is working"
  value       = data.oci_identity_tenancy.current.name
}

# Portfolio site VPS outputs from the compute_portfolio module
output "portfolio_public_ip" {
  description = "Public IP address of the portfolio VPS"
  value       = module.compute_portfolio.public_ip
}

output "portfolio_ssh_command" {
  description = "SSH command to connect to the portfolio VPS"
  value       = "ssh -o IdentitiesOnly=yes ubuntu@${module.compute_portfolio.public_ip}"
}

# Minecraft ARM VPS outputs
output "minecraft_public_ip" {
  description = "Public IP address of the Minecraft (ARM) VPS"
  value       = module.compute_arm.public_ip
}

output "minecraft_ssh_command" {
  description = "SSH command to connect to the Minecraft VPS"
  value       = "ssh -o IdentitiesOnly=yes ubuntu@${module.compute_arm.public_ip}"
}

output "minecraft_connect" {
  description = "Minecraft server address (once deployed)"
  value       = "${module.compute_arm.public_ip}:25565"
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

# OpenVPN VPS outputs
output "vpn_public_ip" {
  description = "Public IP address of the OpenVPN VPS"
  value       = module.compute_openvpn.public_ip
}

output "vpn_ssh_command" {
  description = "SSH command to connect to the OpenVPN VPS"
  value       = "ssh -o IdentitiesOnly=yes ubuntu@${module.compute_openvpn.public_ip}"
}