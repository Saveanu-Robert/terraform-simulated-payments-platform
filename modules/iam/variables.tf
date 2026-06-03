variable "service_name" {
  description = "Service this simulated identity belongs to."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "permissions" {
  description = "Capability flags that determine the least-privilege permission set granted to the service identity."
  type = object({
    database_read  = optional(bool, false)
    database_write = optional(bool, false)
    queue_publish  = optional(bool, false)
    queue_consume  = optional(bool, false)
    secrets_read   = optional(bool, false)
  })
  default  = {}
  nullable = false
}
