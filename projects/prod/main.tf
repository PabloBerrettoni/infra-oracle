# projects/prod/main.tf

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

# OCI Provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Test data source to verify connection
data "oci_identity_tenancy" "current" {
  tenancy_id = var.tenancy_ocid
}

# Create VPS using the module
module "web_vps" {
  source = "../../modules/vps-definition"

  compartment_id  = var.tenancy_ocid # Using root compartment
  instance_name   = "pablo-web-vps"
  hostname_label  = "pablovps"
  ssh_public_keys = var.ssh_public_keys

  # Using half of Always Free resources
  ocpus         = 2
  memory_in_gbs = 12
}