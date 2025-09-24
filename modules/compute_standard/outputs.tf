output "instance_id" {
  value = oci_core_instance.vps_standard.id
}

output "public_ip" {
  value = oci_core_instance.vps_standard.public_ip
}

output "private_ip" {
  value = oci_core_instance.vps_standard.private_ip
}