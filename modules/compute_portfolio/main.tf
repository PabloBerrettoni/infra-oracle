terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.20.0"
    }
  }
}

# Image OCID is pinned via var.image_ocid instead of picking the newest
# image at plan time. Auto-resolving "latest" drifts every time Oracle
# publishes a new build and forces instance replacement (downtime!).

resource "oci_core_instance" "vps_standard" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = var.instance_name
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id                 = var.subnet_id
    display_name              = "${var.instance_name}-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = var.hostname_label
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_ocid
    boot_volume_size_in_gbs = 50
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for key in var.ssh_public_keys : key.publickey])
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      ssh_public_key = join("\n", [for key in var.ssh_public_keys : key.publickey])
      docker_image   = var.docker_image
      container_name = var.container_name
      container_port = var.container_port
      subdomain      = var.subdomain
      domains        = join(" ", var.domains)
      email          = var.email
    }))
  }

  # SSH keys are immutable on OCI instances (API rejects updates) and a
  # metadata change forces replacement. Rotate keys on the OS, not via
  # Terraform, so this never destroys/recreates the VM.
  lifecycle {
    ignore_changes = [metadata["ssh_authorized_keys"]]
  }

  freeform_tags = {
    "Environment" = "production"
    "Purpose"     = "web-hosting"
    "Terraform"   = "true"
  }
}