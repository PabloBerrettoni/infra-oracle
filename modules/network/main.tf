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

# Create VCN
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.network_name}-vcn"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "mainvcn"
}

# Create Internet Gateway
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.network_name}-igw"
}

# Create Route Table
resource "oci_core_default_route_table" "main" {
  manage_default_resource_id = oci_core_vcn.main.default_route_table_id
  display_name               = "${var.network_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }
}

# Create Security List
resource "oci_core_default_security_list" "main" {
  manage_default_resource_id = oci_core_vcn.main.default_security_list_id
  display_name               = "${var.network_name}-sl"

  # Allow outbound traffic
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow SSH
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow HTTP
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  # Allow HTTPS
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }
}

# Create Public Subnet
resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "${var.network_name}-public-subnet"
  dns_label                  = "public"
  availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[0].name
  prohibit_public_ip_on_vnic = false
}