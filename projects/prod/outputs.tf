# projects/prod/outputs.tf

output "tenancy_name" {
  description = "Name of the tenancy - confirms connection is working"
  value       = data.oci_identity_tenancy.current.name
}

# Portfolio VPS outputs from the compute_portfolio module
output "portfolio_public_ip" {
  description = "Public IP address of the portfolio VPS"
  value       = module.compute_portfolio.public_ip
}

output "portfolio_private_ip" {
  description = "Private IP address of the portfolio VPS"
  value       = module.compute_portfolio.private_ip
}

output "portfolio_ssh_command" {
  description = "SSH command to connect to the portfolio VPS"
  value       = "ssh ubuntu@${module.compute_portfolio.public_ip}"
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