# The queue module simulates asynchronous message processing: a main queue, an
# optional retry queue, and an optional dead-letter queue. The optional queues
# demonstrate `count`-based conditional resources referencing the main queue.

locals {
  main_queue_name  = "${var.environment}-${var.name}-queue"
  retry_queue_name = "${var.environment}-${var.name}-retry"
  dlq_name         = "${var.environment}-${var.name}-dlq"
}

resource "terraform_data" "main_queue" {
  input = {
    name                       = local.main_queue_name
    service                    = var.name
    environment                = var.environment
    message_retention_seconds  = var.message_retention_seconds
    visibility_timeout_seconds = var.visibility_timeout_seconds
  }
}

resource "terraform_data" "retry_queue" {
  count = var.retry_queue_enabled ? 1 : 0

  input = {
    name        = local.retry_queue_name
    source      = terraform_data.main_queue.input.name
    environment = var.environment
  }
}

resource "terraform_data" "dead_letter_queue" {
  count = var.dead_letter_queue_enabled ? 1 : 0

  input = {
    name        = local.dlq_name
    source      = terraform_data.main_queue.input.name
    environment = var.environment
  }
}
