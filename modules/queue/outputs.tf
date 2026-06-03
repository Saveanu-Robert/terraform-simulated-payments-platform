output "queue_name" {
  description = "Simulated main queue name."
  value       = local.main_queue_name
}

output "retry_queue_name" {
  description = "Simulated retry queue name, or null when disabled."
  value       = var.retry_queue_enabled ? local.retry_queue_name : null
}

output "dlq_name" {
  description = "Simulated dead-letter queue name, or null when disabled."
  value       = var.dead_letter_queue_enabled ? local.dlq_name : null
}
