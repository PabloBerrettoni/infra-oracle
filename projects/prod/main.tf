# projects/prod/main.tf

terraform {
  required_version = ">= 1.12"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.20.0"
    }
  }
  backend "oci" {
    bucket    = "terraform-state"
    namespace = "grutjt8nmecj"
    region    = "sa-saopaulo-1"
    key       = "prod/terraform.tfstate"
  }
}

# OCI Provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key      = var.private_key != "" ? var.private_key : null
  private_key_path = var.private_key_path != "" ? var.private_key_path : null
  region           = var.region
}

# Test data source to verify connection
data "oci_identity_tenancy" "current" {
  tenancy_id = var.tenancy_ocid
}

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Create DNS Zone and Records
module "dns" {
  source                  = "../../modules/dns"
  tenancy_ocid            = var.tenancy_ocid
  vm_public_ip            = module.compute_portfolio.public_ip
  translate_vm_public_ip  = module.compute_translate.public_ip
}

# Create networking resources
module "network" {
  source = "../../modules/network"

  compartment_id = var.tenancy_ocid
  network_name   = "pablo-web-vps"
}

# Backend bucket creation
module "backend" {
  source           = "../../modules/backend"
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.tenancy_ocid
  region           = var.region
}

# Create Compute Portfolio instance
module "compute_portfolio" {
  source = "../../modules/compute_portfolio"

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.tenancy_ocid
  instance_name       = "pablo-web-vps"
  hostname_label      = "pablovps"
  ssh_public_keys     = var.ssh_public_keys
  subnet_id           = module.network.subnet_id
  docker_image        = "clepo123/main:latest"
  container_name      = "portfolio"
  container_port      = 8082
  subdomain           = "pabloberrettoni.com"
  domains             = ["pabloberrettoni.com", "www.pabloberrettoni.com"]
  email               = "pabloberrettoni98@gmail.com"
}

# Create Compute Translation instance for translation service
module "compute_translate" {
  source = "../../modules/compute_translate"

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.tenancy_ocid
  instance_name       = "srt-translate-vps"
  hostname_label      = "translate"
  ssh_public_keys     = var.ssh_public_keys
  subnet_id           = module.network.subnet_id
  docker_image        = "clepo123/main:srt-translation"
  container_name      = "srt-translate"
  container_port      = 5000
  subdomain           = "translate.pabloberrettoni.com"
  email               = "pabloberrettoni98@gmail.com"
}

# Create Compute ARM instance | Commented out due to region not having the resources available
/* module "compute_arm" {
  source = "../../modules/compute_arm"

  compartment_id  = var.tenancy_ocid
  instance_name   = "pablo-web-vps"
  hostname_label  = "pablovps"
  ssh_public_keys = var.ssh_public_keys
  subnet_id       = module.network.subnet_id
  ocpus           = 2
  memory_in_gbs   = 12
  domain          = "pabloberrettoni.com"
  email           = "pabloberrettoni98@gmail.com"
} */