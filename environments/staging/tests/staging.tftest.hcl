# Environment-level tests for staging.

variables {
  environment   = "staging"
  organization  = "pawapay"
  public_domain = "staging.payments.example.com"

  network = {
    cidr_block = "10.20.0.0/16"
    zones      = ["zone-a", "zone-b", "zone-c"]
  }

  applications = {
    payment-api = {
      owner    = "payments-team"
      image    = "payment-api:1.0.0"
      replicas = 2
      public   = true
      database = {
        enabled        = true
        size           = "medium"
        backup_enabled = true
      }
      queue = {
        enabled                   = true
        dead_letter_queue_enabled = true
      }
      monitoring = {
        enabled = true
        alerts  = { high_error_rate = { threshold = 0.05, severity = "critical" } }
      }
    }
    transaction-worker = {
      owner    = "payments-team"
      image    = "transaction-worker:1.0.0"
      replicas = 2
      database = {
        enabled        = true
        size           = "medium"
        backup_enabled = true
      }
      queue      = { enabled = true, dead_letter_queue_enabled = true }
      monitoring = { enabled = true, alerts = { queue_depth = { threshold = 1000 } } }
    }
  }
}

run "staging_plans_cleanly" {
  command = plan

  assert {
    condition     = length(keys(module.service)) == 2
    error_message = "Staging should compose two services."
  }

  assert {
    condition     = alltrue([for m in module.service : m.service.replicas >= 2])
    error_message = "Staging services should run at least two replicas."
  }
}

run "staging_three_zones" {
  command = plan

  assert {
    condition     = length(module.network.private_subnet_ids) == 3
    error_message = "Staging network should span three zones."
  }
}
