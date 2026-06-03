output "secret_paths" {
  description = "Map of secret name => simulated reference path. Contains no secret values."
  value       = { for name, ref in terraform_data.secret_reference : name => ref.input.path }
}

output "secret_names" {
  description = "Sorted list of modeled secret names."
  value       = sort(var.secret_names)
}
