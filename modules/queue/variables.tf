variable "name" {
  description = "Service name that owns this simulated queue."
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

variable "dead_letter_queue_enabled" {
  description = "Whether to create a simulated dead-letter queue."
  type        = bool
  default     = false
  nullable    = false
}

variable "retry_queue_enabled" {
  description = "Whether to create a simulated retry queue."
  type        = bool
  default     = true
  nullable    = false
}

variable "message_retention_seconds" {
  description = "Simulated message retention period in seconds."
  type        = number
  default     = 86400
  nullable    = false

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds must be between 60 (1m) and 1209600 (14d)."
  }
}

variable "visibility_timeout_seconds" {
  description = "Simulated visibility timeout in seconds."
  type        = number
  default     = 30
  nullable    = false

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "visibility_timeout_seconds must be between 0 and 43200 (12h)."
  }
}
