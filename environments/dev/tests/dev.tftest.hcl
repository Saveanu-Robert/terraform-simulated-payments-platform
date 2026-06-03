# Environment-level tests for dev. These validate the full composition wires up
# correctly. They run against the committed terraform.tfvars by loading the same
# variable values explicitly (tests do not auto-load terraform.tfvars).

variables {
  environment   = "dev"
  organization  = "pawapay"
  public_domain = "dev.payments.example.com"

  network = {
    cidr_block = "10.10.0.0/16"
    zones      = ["zone-a", "zone-b"]
  }

  applications = {
    payment-api = {
      owner    = "payments-team"
      image    = "payment-api:1.0.0"
      replicas = 1
      public   = true
      database = {
        enabled = true
      }
      queue = {
        enabled                   = true
        dead_letter_queue_enabled = true
      }
      monitoring = {
        enabled = true
        alerts = {
          high_error_rate = { threshold = 0.1 }
        }
      }
      permissions = {
        database_read = true
        queue_publish = true
      }
      secrets = ["database-password"]
    }
    transaction-worker = {
      owner    = "payments-team"
      image    = "transaction-worker:1.0.0"
      replicas = 1
      queue = {
        enabled = true
      }
    }
  }
}

run "composition_plans_cleanly" {
  command = plan

  assert {
    condition     = length(keys(module.service)) == 2
    error_message = "Both applications should produce a service."
  }

  assert {
    condition     = length(keys(module.database)) == 1
    error_message = "Only payment-api has a database enabled."
  }

  assert {
    condition     = length(keys(module.monitoring)) == 1
    error_message = "Only payment-api has monitoring enabled."
  }
}

run "service_dependencies_are_wired" {
  command = plan

  assert {
    condition     = contains(module.service["payment-api"].service.dependencies, "dev-payment-api-db")
    error_message = "payment-api should depend on its database."
  }

  assert {
    condition     = contains(module.service["payment-api"].service.dependencies, "dev-payment-api-queue")
    error_message = "payment-api should depend on its queue."
  }
}

run "full_apply_generates_manifests" {
  command = apply

  assert {
    condition     = output.services["payment-api"].public == true
    error_message = "payment-api should be public in the services output."
  }

  assert {
    condition     = length(output.manifest_paths["payment-api"]) == 4
    error_message = "payment-api should generate four manifest files."
  }

  assert {
    condition     = output.queues["payment-api"].dlq_enabled == true
    error_message = "payment-api queue should have a DLQ."
  }
}
