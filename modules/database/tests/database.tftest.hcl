# Tests for the database module. All values are input-derived (no random), so
# `command = plan` is sufficient throughout.

run "creates_primary_database" {
  command = plan

  variables {
    name           = "payment-api"
    environment    = "dev"
    engine         = "postgres"
    size           = "small"
    backup_enabled = false
    read_replica   = false
  }

  assert {
    condition     = output.database_name == "dev-payment-api-db"
    error_message = "Database name should follow <env>-<service>-db."
  }

  assert {
    condition     = output.replica_name == null
    error_message = "replica_name should be null when read_replica is false."
  }

  assert {
    condition     = output.connection_metadata.port == 5432
    error_message = "Postgres databases should report port 5432."
  }
}

run "creates_read_replica_when_requested" {
  command = plan

  variables {
    name           = "payment-api"
    environment    = "staging"
    engine         = "mysql"
    size           = "medium"
    backup_enabled = true
    read_replica   = true
  }

  assert {
    condition     = output.replica_name == "staging-payment-api-db-replica"
    error_message = "replica_name should be populated when read_replica is true."
  }

  assert {
    condition     = output.connection_metadata.port == 3306
    error_message = "MySQL databases should report port 3306."
  }
}

# Negative test: prod databases must have backups enabled (precondition).
run "prod_requires_backups" {
  command = plan

  variables {
    name           = "payment-api"
    environment    = "prod"
    engine         = "postgres"
    size           = "large"
    backup_enabled = false
    read_replica   = true
  }

  expect_failures = [
    terraform_data.database,
  ]
}

# Negative test: prod databases must not use the small size (precondition).
run "prod_forbids_small_size" {
  command = plan

  variables {
    name           = "payment-api"
    environment    = "prod"
    engine         = "postgres"
    size           = "small"
    backup_enabled = true
    read_replica   = true
  }

  expect_failures = [
    terraform_data.database,
  ]
}
