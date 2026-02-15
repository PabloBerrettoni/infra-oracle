output "public_ip" {
  value = oci_core_instance.vpn.public_ip
}

output "instance_id" {
  value = oci_core_instance.vpn.id
}
