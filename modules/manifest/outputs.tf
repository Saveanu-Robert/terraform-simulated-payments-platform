output "manifest_paths" {
  description = "List of generated manifest file paths."
  value = [
    local_file.service_manifest.filename,
    local_file.deployment_manifest.filename,
    local_file.alerts_manifest.filename,
    local_file.dependencies_manifest.filename,
  ]
}

output "service_dir" {
  description = "Directory under which this service's manifests are generated."
  value       = local.service_dir
}
