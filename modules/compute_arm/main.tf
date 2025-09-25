terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.20.0"
    }
  }
}

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Get the latest Ubuntu 24.04 image for ARM shape
data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Create the VPS Instance
resource "oci_core_instance" "vps" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = var.instance_name
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id                 = var.subnet_id
    display_name              = "${var.instance_name}-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = var.hostname_label
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for key in var.ssh_public_keys : key.publickey])
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      ssh_public_keys = var.ssh_public_keys
      domain          = var.domain
      email           = var.email
    }))
  }

  freeform_tags = {
    "Environment" = "production"
    "Purpose"     = "web-hosting"
    "Terraform"   = "true"
  }
}