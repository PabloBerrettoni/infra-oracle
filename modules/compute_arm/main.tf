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

# Image OCID is pinned via var.image_ocid instead of picking the newest
# image at plan time (avoids drift-forced replacement like compute_portfolio).

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
    source_id   = var.image_ocid
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for key in var.ssh_public_keys : key.publickey])
    user_data           = base64encode(templatefile("${path.module}/cloud-init.yaml", {}))
  }

  # metadata (ssh keys + user_data/cloud-init) is a ForceNew field in the
  # OCI provider - ANY change would destroy & recreate the VM. Instance-level
  # changes (rotating SSH keys, applying cloud-init updates) are done on the
  # OS instead, so Terraform never rebuilds the box for them.
  lifecycle {
    ignore_changes = [metadata]
  }

  freeform_tags = {
    "Environment" = "production"
    "Purpose"     = "minecraft-server"
    "Terraform"   = "true"
  }
}