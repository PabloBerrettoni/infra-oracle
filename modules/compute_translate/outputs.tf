output "instance_id" {
  value = oci_core_instance.vps_free.id
}

output "public_ip" {
  value = oci_core_instance.vps_free.public_ip
}

output "private_ip" {
  value = oci_core_instance.vps_free.private_ip
}
