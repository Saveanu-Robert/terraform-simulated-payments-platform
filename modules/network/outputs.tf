output "network_name" {
  description = "Simulated network name (includes a generated suffix, known after apply)."
  value       = local.network_name
}

# Built with a `for` expression over the for_each map. Splat ([*]) would NOT
# work here because for_each resources are maps, not count-indexed lists.
output "private_subnet_ids" {
  description = "Names of the simulated private subnets, one per zone."
  value       = [for s in terraform_data.private_subnets : s.input.name]
}

output "public_subnet_ids" {
  description = "Names of the simulated public subnets, one per zone."
  value       = [for s in terraform_data.public_subnets : s.input.name]
}

output "private_subnets_by_zone" {
  description = "Map of zone => private subnet name."
  value       = { for zone, s in terraform_data.private_subnets : zone => s.input.name }
}

output "service_discovery_namespace" {
  description = "Simulated internal service-discovery namespace."
  value       = terraform_data.service_discovery_namespace.input.name
}
