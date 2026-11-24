# The naming module centralizes naming + tagging conventions for the whole
# platform. It declares NO resources — it is a pure "computation" module that
# turns inputs into a standard name and a canonical tag set. This is a common,
# valuable pattern: a module can be just a typed, validated function.

locals {
  standard_name = "${var.organization}-${var.environment}-${var.service_name}"

  standard_tags = {
    organization = var.organization
    environment  = var.environment
    service      = var.service_name
    managed_by   = "terraform"
    simulated    = "true"
  }

  # Standard tags listed LAST so reserved keys (environment, managed_by, ...)
  # always win and cannot be overridden by caller-supplied extra_tags.
  tags = merge(var.extra_tags, local.standard_tags)
}
