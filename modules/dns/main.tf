terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.20.0"
    }
  }
}

locals {
  # Fully-qualified domain for each record: "" means the apex.
  fqdns = {
    for r in var.records :
    (r.name == "" ? var.zone_name : "${r.name}.${var.zone_name}") => r
  }
}

resource "oci_dns_zone" "zone" {
  compartment_id = var.compartment_id
  name           = var.zone_name
  zone_type      = "PRIMARY"
}

# One A record per entry in var.records.
resource "oci_dns_rrset" "a_records" {
  for_each = local.fqdns

  zone_name_or_id = oci_dns_zone.zone.id
  domain          = each.key
  rtype           = "A"

  items {
    domain = each.key
    rtype  = "A"
    ttl    = var.ttl
    rdata  = each.value.ip
  }
}

# --- One-time migration of this deployment's pre-refactor state -------------
# Moved blocks only apply when the source exists in state, so fresh users
# (or anyone who already applied this refactor) are unaffected. Safe to
# delete once this commit's apply has run.
moved {
  from = oci_dns_zone.portfolio_zone
  to   = oci_dns_zone.zone
}

moved {
  from = oci_dns_rrset.a_record
  to   = oci_dns_rrset.a_records["pabloberrettoni.com"]
}

moved {
  from = oci_dns_rrset.www_record
  to   = oci_dns_rrset.a_records["www.pabloberrettoni.com"]
}

moved {
  from = oci_dns_rrset.crafty_record
  to   = oci_dns_rrset.a_records["crafty.pabloberrettoni.com"]
}
