# The iam module simulates a service identity with a least-privilege policy.
# The permission list is derived from boolean capability flags — services only
# receive a permission when they actually declare the matching capability.

locals {
  # Map each capability flag to its permission string, then keep only the
  # enabled ones. This is the modern, readable alternative to compact() over
  # a list of ternaries-to-empty-string.
  permission_catalog = {
    database_read  = "database:read"
    database_write = "database:write"
    queue_publish  = "queue:publish"
    queue_consume  = "queue:consume"
    secrets_read   = "secrets:read"
  }

  # Iterate the typed permissions object directly: each granted flag maps to its
  # permission string via the catalog. Sorted for a stable, deterministic output.
  permission_list = sort([
    for flag, granted in var.permissions : local.permission_catalog[flag]
    if granted
  ])

  role_name = "${var.environment}-${var.service_name}-role"
}

resource "terraform_data" "service_role" {
  input = {
    role        = local.role_name
    service     = var.service_name
    environment = var.environment
    permissions = local.permission_list
  }
}
