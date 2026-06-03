# Tests for the queue module. All input-derived, so `command = plan` suffices.

run "creates_main_queue" {
  command = plan

  variables {
    name                      = "transaction-worker"
    environment               = "dev"
    dead_letter_queue_enabled = false
    retry_queue_enabled       = false
  }

  assert {
    condition     = output.queue_name == "dev-transaction-worker-queue"
    error_message = "Main queue name should follow <env>-<service>-queue."
  }

  assert {
    condition     = output.dlq_name == null
    error_message = "dlq_name should be null when the DLQ is disabled."
  }

  assert {
    condition     = output.retry_queue_name == null
    error_message = "retry_queue_name should be null when the retry queue is disabled."
  }
}

run "creates_dlq_and_retry_when_enabled" {
  command = plan

  variables {
    name                      = "transaction-worker"
    environment               = "prod"
    dead_letter_queue_enabled = true
    retry_queue_enabled       = true
  }

  assert {
    condition     = output.dlq_name == "prod-transaction-worker-dlq"
    error_message = "dlq_name should be populated when the DLQ is enabled."
  }

  assert {
    condition     = output.retry_queue_name == "prod-transaction-worker-retry"
    error_message = "retry_queue_name should be populated when the retry queue is enabled."
  }
}

# Negative test: retention out of range fails validation.
run "rejects_excessive_retention" {
  command = plan

  variables {
    name                      = "transaction-worker"
    environment               = "dev"
    message_retention_seconds = 9999999
  }

  expect_failures = [
    var.message_retention_seconds,
  ]
}
