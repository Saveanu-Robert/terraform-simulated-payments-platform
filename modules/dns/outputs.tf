output "internal_hostname" {
  description = "Simulated internal DNS hostname."
  value       = local.internal_hostname
}

output "public_hostname" {
  description = "Simulated public DNS hostname, or null when the service is not public."
  value       = var.public ? local.public_hostname : null
}
