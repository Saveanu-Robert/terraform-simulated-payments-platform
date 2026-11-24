output "database_name" {
  description = "Simulated primary database name."
  value       = local.database_name
}

output "replica_name" {
  description = "Simulated read replica name, or null when no replica is created."
  value       = var.read_replica ? local.replica_name : null
}

output "connection_metadata" {
  description = "Simulated, non-sensitive connection metadata for the database."
  value = {
    host   = "${local.database_name}.${var.environment}.db.internal"
    port   = var.engine == "mysql" || var.engine == "mariadb" ? 3306 : 5432
    engine = var.engine
  }
}
