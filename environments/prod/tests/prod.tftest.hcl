# Environment-level tests for prod, including negative guardrail tests.

variables {
  environment   = "prod"
  organization  = "pawapay"
  public_domain = "payments.example.com"

  network = {
    cidr_block = "10.30.0.0/16"
    zones      = ["zone-a", "zone-b", "zone-c"]
  }

  applications = {
    payment-api = {
      owner    = "payments-team"
      image    = "payment-api:1.0.0"
      replicas = 3
      public   = true
      database = {
        enabled        = true
        size           = "large"
        backup_enabled = true
        read_replica   = true
      }
      queue = { enabled = true, dead_letter_queue_enabled = true }
      monitoring = {
        enabled = true
        alerts  = { high_error_rate = { threshold = 0.01, severity = "critical" } }
      }
      permissions = { database_read = true, database_write = true, secrets_read = true }
      secrets     = ["database-password"]
    }
    refund-api = {
      owner    = "payments-team"
      image    = "refund-api:1.0.0"
      replicas = 2
      public   = true
      database = {
        enabled        = true
        size           = "medium"
        backup_enabled = true
      }
      queue = { enabled = true, dead_letter_queue_enabled = true }
      monitoring = {
        enabled = true
        alerts  = { high_error_rate = { threshold = 0.02, severity = "critical" } }
      }
      secrets = ["database-password", "refund-signing-key"]
    }
  }
}

run "prod_capstone_composition" {
  command = plan

  assert {
    condition     = contains(keys(module.service), "refund-api")
    error_message = "The refund-api capstone service should be present in prod."
  }

  assert {
    condition     = alltrue([for m in module.service : m.service.replicas >= 2])
    error_message = "All production services must run at least two replicas."
  }

  assert {
    condition     = module.database["refund-api"].database_name == "prod-refund-api-db"
    error_message = "refund-api should get a production database."
  }
}

run "prod_full_apply" {
  command = apply

  assert {
    condition     = output.queues["refund-api"].dlq_enabled == true
    error_message = "refund-api queue must have a DLQ in prod."
  }

  assert {
    condition     = length(output.manifest_paths["refund-api"]) == 4
    error_message = "refund-api should generate four manifests."
  }

  assert {
    condition     = output.dns_records["refund-api"].public == "refund-api.payments.example.com"
    error_message = "refund-api should have a public DNS record."
  }
}

# Negative test at the environment level: the `applications` variable validation
# rejects a service with fewer than one replica. (Root variables are checkable
# objects, so they CAN appear in expect_failures.)
#
# Production *precondition* guardrails — prod requires >= 2 replicas, prod
# databases require backups — live in the module-level tests
# (modules/service/tests and modules/database/tests), because expect_failures
# cannot target a resource nested inside a child module.
run "rejects_zero_replicas" {
  command = plan

  variables {
    applications = {
      payment-api = {
        owner    = "payments-team"
        image    = "payment-api:1.0.0"
        replicas = 0
        public   = true
      }
    }
  }

  expect_failures = [
    var.applications,
  ]
}
