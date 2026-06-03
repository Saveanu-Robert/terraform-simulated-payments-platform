variable "service_name" {
  description = "Service being monitored."
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

variable "alerts" {
  description = "Map of alert name => alert definition (threshold + severity)."
  type = map(object({
    threshold = number
    severity  = optional(string, "warning")
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for a in values(var.alerts) : contains(["info", "warning", "critical"], a.severity)
    ])
    error_message = "Each alert severity must be one of: info, warning, critical."
  }
}

variable "slo_availability" {
  description = "Target availability SLO as a fraction (e.g. 0.999)."
  type        = number
  default     = 0.99
  nullable    = false

  validation {
    condition     = var.slo_availability > 0 && var.slo_availability <= 1
    error_message = "slo_availability must be between 0 (exclusive) and 1 (inclusive)."
  }
}
