output "standard_name" {
  description = "Canonical resource name: <organization>-<environment>-<service_name>."
  value       = local.standard_name
}

output "tags" {
  description = "Standard tag set (organization, environment, service, managed_by, simulated) merged with any extra_tags."
  value       = local.tags
}
