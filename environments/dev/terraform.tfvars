environment   = "dev"
organization  = "pawapay"
public_domain = "dev.payments.example.com"

network = {
  cidr_block = "10.10.0.0/16"
  zones      = ["zone-a", "zone-b"]
}

# Dev: the full mobile-money payments platform with relaxed posture — single
# replicas, backups optional, small databases, lighter alerting. Every service
# from the business domain is present so dev mirrors the real topology.
applications = {
  # Public edge: accepts and validates payment requests.
  payment-api = {
    owner       = "payments-team"
    cost_center = "payments"
    image       = "payment-api:1.4.0"
    replicas    = 1
    public      = true

    database = { enabled = true, engine = "postgres", size = "small" }
    queue    = { enabled = true, dead_letter_queue_enabled = true }
    monitoring = {
      enabled = true
      alerts  = { high_error_rate = { threshold = 0.10, severity = "warning" } }
    }
    permissions = { database_read = true, database_write = true, queue_publish = true, secrets_read = true }
    secrets     = ["database-password", "api-token"]
  }

  # Merchant-facing dashboard.
  merchant-portal = {
    owner       = "merchant-team"
    cost_center = "merchant"
    image       = "merchant-portal:0.9.0"
    replicas    = 1
    public      = true

    database    = { enabled = true, engine = "postgres", size = "small" }
    monitoring  = { enabled = true, alerts = { high_error_rate = { threshold = 0.15 } } }
    permissions = { database_read = true, secrets_read = true }
    secrets     = ["session-key"]
  }

  # Processes asynchronous transaction jobs.
  transaction-worker = {
    owner       = "payments-team"
    cost_center = "payments"
    image       = "transaction-worker:1.4.0"
    replicas    = 1
    public      = false

    database    = { enabled = true, engine = "postgres", size = "small" }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { queue_depth = { threshold = 5000 } } }
    permissions = { queue_consume = true, database_read = true, secrets_read = true }
    secrets     = ["database-password"]
  }

  # Handles refund requests.
  refund-api = {
    owner       = "payments-team"
    cost_center = "payments"
    image       = "refund-api:1.1.0"
    replicas    = 1
    public      = true

    database    = { enabled = true, engine = "postgres", size = "small" }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { high_error_rate = { threshold = 0.10 } } }
    permissions = { database_read = true, database_write = true, queue_publish = true, secrets_read = true }
    secrets     = ["database-password", "refund-signing-key"]
  }

  # Simulates merchant settlement runs.
  settlement-worker = {
    owner       = "settlements-team"
    cost_center = "payments"
    image       = "settlement-worker:1.0.0"
    replicas    = 1
    public      = false

    database    = { enabled = true, engine = "postgres", size = "small" }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { queue_depth = { threshold = 2000 } } }
    permissions = { queue_consume = true, database_read = true, database_write = true, secrets_read = true }
    secrets     = ["database-password", "settlement-signing-key"]
  }

  # Sends simulated webhooks / SMS / email notifications.
  notification-service = {
    owner       = "platform-team"
    cost_center = "platform"
    image       = "notification-service:2.0.0"
    replicas    = 1
    public      = false

    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { delivery_failures = { threshold = 0.05 } } }
    permissions = { queue_consume = true, secrets_read = true }
    secrets     = ["smtp-password", "sms-api-key"]
  }

  # Evaluates suspicious transaction patterns.
  fraud-service = {
    owner       = "risk-team"
    cost_center = "risk"
    image       = "fraud-service:0.5.0"
    replicas    = 1
    public      = false

    database    = { enabled = true, engine = "postgres", size = "small" }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { model_latency = { threshold = 250 } } }
    permissions = { queue_consume = true, database_read = true, secrets_read = true }
    secrets     = ["model-api-key"]
  }

  # Compares internal and external transaction records.
  reconciliation-service = {
    owner       = "finance-team"
    cost_center = "finance"
    image       = "reconciliation-service:1.2.0"
    replicas    = 1
    public      = false

    database    = { enabled = true, engine = "mysql", size = "small" }
    monitoring  = { enabled = true, alerts = { mismatch_rate = { threshold = 0.01 } } }
    permissions = { database_read = true, secrets_read = true }
    secrets     = ["database-password"]
  }
}
