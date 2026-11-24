output "dashboard_name" {
  description = "Simulated dashboard name."
  value       = local.dashboard_name
}

output "alert_names" {
  description = "Sorted list of configured alert names."
  value       = sort(keys(var.alerts))
}

output "slo_availability" {
  description = "Configured availability SLO."
  value       = var.slo_availability
}
