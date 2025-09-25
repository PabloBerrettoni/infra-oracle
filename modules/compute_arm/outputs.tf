output "instance_id" {
  value = oci_core_instance.vps.id
}
output "public_ip" {
  value = oci_core_instance.vps.public_ip
}