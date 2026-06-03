output "network_name" {
  description = "Simulated network name for this environment."
  value       = module.network.network_name
}

output "standard_names" {
  description = "Map of service name => canonical <org>-<env>-<service> name."
  value       = { for name, m in module.naming : name => m.standard_name }
}

output "tags" {
  description = "Map of service name => standard tag set."
  value       = { for name, m in module.naming : name => m.tags }
}

output "services" {
  description = "Map of service name => summary (replicas, public, owner)."
  value = {
    for name, m in module.service : name => {
      replicas = m.service.replicas
      public   = m.service.public
      owner    = m.service.owner
    }
  }
}

output "databases" {
  description = "Map of service name => database summary."
  value = {
    for name, m in module.database : name => {
      name           = m.database_name
      backup_enabled = var.applications[name].database.backup_enabled
      engine         = var.applications[name].database.engine
    }
  }
}

output "queues" {
  description = "Map of service name => queue summary."
  value = {
    for name, m in module.queue : name => {
      name        = m.queue_name
      dlq_enabled = m.dlq_name != null
    }
  }
}

output "dns_records" {
  description = "Map of service name => internal/public hostnames."
  value = {
    for name, m in module.dns : name => {
      internal = m.internal_hostname
      public   = m.public_hostname
    }
  }
}

output "iam_roles" {
  description = "Map of service name => granted permissions."
  value = {
    for name, m in module.iam : name => m.permissions
  }
}

output "manifest_paths" {
  description = "All generated manifest file paths, by service."
  value = {
    for name, m in module.manifest : name => m.manifest_paths
  }
}
