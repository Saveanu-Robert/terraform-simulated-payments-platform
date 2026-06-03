# The dns module simulates an internal service record and, optionally, a public
# record. The public record uses `count` for the simple create/don't toggle.

locals {
  internal_hostname = "${var.service_name}.${var.environment}.internal"
  public_hostname   = "${var.service_name}.${var.public_domain}"
  target            = var.service_target != "" ? var.service_target : local.internal_hostname
}

resource "terraform_data" "internal_record" {
  input = {
    hostname    = local.internal_hostname
    type        = "internal"
    target      = local.target
    environment = var.environment
  }
}

resource "terraform_data" "public_record" {
  count = var.public ? 1 : 0

  input = {
    hostname    = local.public_hostname
    type        = "public"
    target      = local.target
    environment = var.environment
  }
}
