# Tests for the iam module. Input-derived, so `command = plan` suffices.

run "grants_only_declared_permissions" {
  command = plan

  variables {
    service_name = "payment-api"
    environment  = "dev"
    permissions = {
      database_read = true
      queue_publish = true
    }
  }

  assert {
    condition     = output.permissions == tolist(["database:read", "queue:publish"])
    error_message = "Only declared capabilities should be granted, sorted."
  }

  assert {
    condition     = output.role_name == "dev-payment-api-role"
    error_message = "Role name should follow <env>-<service>-role."
  }
}

run "no_permissions_by_default" {
  command = plan

  variables {
    service_name = "merchant-portal"
    environment  = "dev"
  }

  assert {
    condition     = length(output.permissions) == 0
    error_message = "With no capability flags set, no permissions should be granted."
  }
}

run "full_permission_set" {
  command = plan

  variables {
    service_name = "reconciliation-service"
    environment  = "prod"
    permissions = {
      database_read  = true
      database_write = true
      queue_publish  = true
      queue_consume  = true
      secrets_read   = true
    }
  }

  assert {
    condition     = length(output.permissions) == 5
    error_message = "All five capabilities should produce five permissions."
  }
}
