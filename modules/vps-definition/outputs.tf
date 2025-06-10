# modules/vps-definition/outputs.tf

output "instance_id" {
  description = "OCID of the created instance"
  value       = oci_core_instance.vps.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = oci_core_instance.vps.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = oci_core_instance.vps.private_ip
}

output "instance_name" {
  description = "Display name of the instance"
  value       = oci_core_instance.vps.display_name
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh ubuntu@${oci_core_instance.vps.public_ip}"
}

output "vcn_id" {
  description = "OCID of the VCN created for this instance"
  value       = oci_core_vcn.main.id
}

output "subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public.id
}