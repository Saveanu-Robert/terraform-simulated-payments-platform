environment   = "prod"
organization  = "pawapay"
public_domain = "payments.example.com"

network = {
  cidr_block = "10.30.0.0/16"
  zones      = ["zone-a", "zone-b", "zone-c"]
}

# Prod: strongest guardrails. Every service has an owner; >= 2 replicas;
# databases have backups and are never 'small'; workers use DLQs; public
# services have monitoring + alerts; secrets are references only. Hot paths run
# read replicas and larger instances.
applications = {
  payment-api = {
    owner       = "payments-team"
    cost_center = "payments"
    image       = "payment-api:1.4.0"
    replicas    = 3
    public      = true

    database = { enabled = true, engine = "postgres", size = "large", backup_enabled = true, read_replica = true }
    queue    = { enabled = true, dead_letter_queue_enabled = true }
    monitoring = {
      enabled = true
      alerts = {
        high_error_rate = { threshold = 0.01, severity = "critical" }
        high_latency    = { threshold = 300, severity = "critical" }
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
    monitoring  = { enabled = true, alerts = { high_error_rate = { threshold = 0.02, severity = "critical" } } }
    permissions = { database_read = true, secrets_read = true }
    secrets     = ["session-key"]
  }

  transaction-worker = {
    owner       = "payments-team"
    cost_center = "payments"
    image       = "transaction-worker:1.4.0"
    replicas    = 3
    public      = false

    database    = { enabled = true, engine = "postgres", size = "large", backup_enabled = true, read_replica = true }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { queue_depth = { threshold = 500, severity = "critical" } } }
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
    monitoring  = { enabled = true, alerts = { high_error_rate = { threshold = 0.02, severity = "critical" } } }
    permissions = { database_read = true, database_write = true, queue_publish = true, secrets_read = true }
    secrets     = ["database-password", "refund-signing-key"]
  }

  settlement-worker = {
    owner       = "settlements-team"
    cost_center = "payments"
    image       = "settlement-worker:1.0.0"
    replicas    = 2
    public      = false

    database    = { enabled = true, engine = "postgres", size = "large", backup_enabled = true }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { queue_depth = { threshold = 250, severity = "critical" } } }
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
    monitoring  = { enabled = true, alerts = { delivery_failures = { threshold = 0.02, severity = "critical" } } }
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
    monitoring  = { enabled = true, alerts = { model_latency = { threshold = 150, severity = "critical" } } }
    permissions = { queue_consume = true, database_read = true, secrets_read = true }
    secrets     = ["model-api-key"]
  }

  reconciliation-service = {
    owner       = "finance-team"
    cost_center = "finance"
    image       = "reconciliation-service:1.2.0"
    replicas    = 2
    public      = false

    database    = { enabled = true, engine = "mysql", size = "large", backup_enabled = true }
    monitoring  = { enabled = true, alerts = { mismatch_rate = { threshold = 0.001, severity = "critical" } } }
    permissions = { database_read = true, secrets_read = true }
    secrets     = ["database-password"]
  }
}
