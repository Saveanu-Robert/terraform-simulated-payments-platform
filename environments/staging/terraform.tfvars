environment   = "staging"
organization  = "pawapay"
public_domain = "staging.payments.example.com"

network = {
  cidr_block = "10.20.0.0/16"
  zones      = ["zone-a", "zone-b", "zone-c"]
}

# Staging: production-like posture — >= 2 replicas, backups enabled, medium
# databases, three zones, realistic alerting. Mirrors prod for safe rehearsal.
applications = {
  payment-api = {
    owner       = "payments-team"
    cost_center = "payments"
    image       = "payment-api:1.4.0"
    replicas    = 2
    public      = true

    database = { enabled = true, engine = "postgres", size = "medium", backup_enabled = true }
    queue    = { enabled = true, dead_letter_queue_enabled = true }
    monitoring = {
      enabled = true
      alerts = {
        high_error_rate = { threshold = 0.05, severity = "critical" }
        high_latency    = { threshold = 500, severity = "warning" }
      }
    }
    permissions = { database_read = true, database_write = true, queue_publish = true, secrets_read = true }
    secrets     = ["database-password", "api-token"]
  }

  merchant-portal = {
    owner       = "merchant-team"
    cost_center = "merchant"
    image       = "merchant-portal:0.9.0"
    replicas    = 2
    public      = true

    database    = { enabled = true, engine = "postgres", size = "medium", backup_enabled = true }
    monitoring  = { enabled = true, alerts = { high_error_rate = { threshold = 0.08, severity = "warning" } } }
    permissions = { database_read = true, secrets_read = true }
    secrets     = ["session-key"]
  }

  transaction-worker = {
    owner       = "payments-team"
    cost_center = "payments"
    image       = "transaction-worker:1.4.0"
    replicas    = 2
    public      = false

    database    = { enabled = true, engine = "postgres", size = "medium", backup_enabled = true }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { queue_depth = { threshold = 2000, severity = "warning" } } }
    permissions = { queue_consume = true, database_read = true, secrets_read = true }
    secrets     = ["database-password"]
  }

  refund-api = {
    owner       = "payments-team"
    cost_center = "payments"
    image       = "refund-api:1.1.0"
    replicas    = 2
    public      = true

    database    = { enabled = true, engine = "postgres", size = "medium", backup_enabled = true }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { high_error_rate = { threshold = 0.05, severity = "critical" } } }
    permissions = { database_read = true, database_write = true, queue_publish = true, secrets_read = true }
    secrets     = ["database-password", "refund-signing-key"]
  }

  settlement-worker = {
    owner       = "settlements-team"
    cost_center = "payments"
    image       = "settlement-worker:1.0.0"
    replicas    = 2
    public      = false

    database    = { enabled = true, engine = "postgres", size = "medium", backup_enabled = true }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { queue_depth = { threshold = 1000, severity = "warning" } } }
    permissions = { queue_consume = true, database_read = true, database_write = true, secrets_read = true }
    secrets     = ["database-password", "settlement-signing-key"]
  }

  notification-service = {
    owner       = "platform-team"
    cost_center = "platform"
    image       = "notification-service:2.0.0"
    replicas    = 2
    public      = false

    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { delivery_failures = { threshold = 0.03, severity = "warning" } } }
    permissions = { queue_consume = true, secrets_read = true }
    secrets     = ["smtp-password", "sms-api-key"]
  }

  fraud-service = {
    owner       = "risk-team"
    cost_center = "risk"
    image       = "fraud-service:0.5.0"
    replicas    = 2
    public      = false

    database    = { enabled = true, engine = "postgres", size = "medium", backup_enabled = true }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { model_latency = { threshold = 200, severity = "warning" } } }
    permissions = { queue_consume = true, database_read = true, secrets_read = true }
    secrets     = ["model-api-key"]
  }

  reconciliation-service = {
    owner       = "finance-team"
    cost_center = "finance"
    image       = "reconciliation-service:1.2.0"
    replicas    = 2
    public      = false

    database    = { enabled = true, engine = "mysql", size = "medium", backup_enabled = true }
    monitoring  = { enabled = true, alerts = { mismatch_rate = { threshold = 0.005, severity = "critical" } } }
    permissions = { database_read = true, secrets_read = true }
    secrets     = ["database-password"]
  }
}
