provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
}

# Namespace necesario para crear buckets
data "oci_objectstorage_namespace" "ns" {}

# Bucket para Terraform state
resource "oci_objectstorage_bucket" "tfstate_bucket" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "terraform-state"
  storage_tier   = "Standard"
}