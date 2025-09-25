terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.20.0"
    }
  }
}

resource "oci_dns_zone" "portfolio_zone" {
  compartment_id = var.tenancy_ocid
  name           = "pabloberrettoni.com"
  zone_type      = "PRIMARY"
}

resource "oci_dns_rrset" "a_record" {
  domain          = "pabloberrettoni.com"
  rtype           = "A"
  zone_name_or_id = oci_dns_zone.portfolio_zone.id
  items {
    domain = "pabloberrettoni.com"
    rtype  = "A"
    ttl    = 300
    rdata  = var.vm_public_ip
  }
}

resource "oci_dns_rrset" "www_record" {
  domain          = "www.pabloberrettoni.com"
  rtype           = "A"
  zone_name_or_id = oci_dns_zone.portfolio_zone.id
  items {
    domain = "www.pabloberrettoni.com"
    rtype  = "A"
    ttl    = 300
    rdata  = var.vm_public_ip
  }
}
