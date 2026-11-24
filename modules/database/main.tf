# The database module simulates a primary database plus an optional read
# replica. Production guardrails (backups required, no `small` in prod) are
# enforced with lifecycle preconditions.

locals {
  database_name = "${var.environment}-${var.name}-db"
  replica_name  = "${var.environment}-${var.name}-db-replica"
}

resource "terraform_data" "database" {
  input = {
    name               = local.database_name
    service            = var.name
    environment        = var.environment
    engine             = var.engine
    size               = var.size
    backup_enabled     = var.backup_enabled
    retention_days     = var.retention_days
    private_subnet_ids = var.private_subnet_ids
  }

  lifecycle {
    precondition {
      condition     = var.environment != "prod" || var.backup_enabled
      error_message = "Production databases must have backups enabled (service ${var.name})."
    }

    precondition {
      condition     = var.environment != "prod" || var.size != "small"
      error_message = "Production databases must not use the 'small' size (service ${var.name})."
    }
  }
}

# Optional read replica. `count` is the right tool for a simple boolean toggle.
resource "terraform_data" "read_replica" {
  count = var.read_replica ? 1 : 0

  input = {
    name        = local.replica_name
    source      = terraform_data.database.input.name
    environment = var.environment
    engine      = var.engine
  }
}
