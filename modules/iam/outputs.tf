output "role_name" {
  description = "Simulated service role name."
  value       = local.role_name
}

output "permissions" {
  description = "Sorted list of granted permission strings (least-privilege)."
  value       = local.permission_list
}
