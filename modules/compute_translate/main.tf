terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.20.0"
    }
  }
}

data "oci_core_images" "ubuntu_minimal" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "vps_free" {
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
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_minimal.images[0].id
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for key in var.ssh_public_keys : key.publickey])
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      ssh_public_key = join("\n", [for key in var.ssh_public_keys : key.publickey])
      docker_image   = var.docker_image
      container_name = var.container_name
      container_port = var.container_port
      subdomain      = var.subdomain
      email          = var.email
    }))
  }

  freeform_tags = {
    "Environment" = "production"
    "Purpose"     = "web-hosting"
    "Terraform"   = "true"
  }
}

