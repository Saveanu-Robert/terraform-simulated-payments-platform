variable "organization" {
  description = "Organization / platform prefix for all simulated resources."
  type        = string
  default     = "pawapay"
}

variable "environment" {
  description = "Deployment environment for this root module."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "network" {
  description = "Network configuration for the simulated payments platform."
  type = object({
    cidr_block = string
    zones      = list(string)
  })
}

variable "public_domain" {
  description = "Public domain used for public service hostnames."
  type        = string
  default     = "payments.example.com"
}

# The single high-level application model. This is the heart of the platform:
# one typed map drives every module via for_each. Optional() typed defaults let
# environments specify only what differs from sensible defaults.
variable "applications" {
  description = "Applications to onboard into the simulated payments platform."

  type = map(object({
    owner            = string
    cost_center      = optional(string, "unallocated")
    image            = string
    replicas         = number
    public           = optional(bool, false)
    rollout_strategy = optional(string, "rolling")

    database = optional(object({
      enabled        = optional(bool, false)
      engine         = optional(string, "postgres")
      size           = optional(string, "small")
      backup_enabled = optional(bool, false)
      read_replica   = optional(bool, false)
    }), {})

    queue = optional(object({
      enabled                    = optional(bool, false)
      dead_letter_queue_enabled  = optional(bool, false)
      retry_queue_enabled        = optional(bool, true)
      message_retention_seconds  = optional(number, 86400)
      visibility_timeout_seconds = optional(number, 30)
    }), {})

    monitoring = optional(object({
      enabled = optional(bool, false)
      alerts = optional(map(object({
        threshold = number
        severity  = optional(string, "warning")
      })), {})
    }), {})

    permissions = optional(object({
      database_read  = optional(bool, false)
      database_write = optional(bool, false)
      queue_publish  = optional(bool, false)
      queue_consume  = optional(bool, false)
      secrets_read   = optional(bool, false)
    }), {})

    secrets = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for app in values(var.applications) : app.replicas >= 1
    ])
    error_message = "Every application must have at least one replica."
  }

  validation {
    condition = alltrue([
      for name, app in var.applications : can(regex("^[a-z][a-z0-9-]{2,40}$", name))
    ])
    error_message = "Application names must be lowercase kebab-case and start with a letter."
  }
}
