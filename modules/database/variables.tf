variable "name" {
  description = "Service name that owns this simulated database."
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

variable "engine" {
  description = "Simulated database engine."
  type        = string
  default     = "postgres"
  nullable    = false

  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.engine)
    error_message = "engine must be one of: postgres, mysql, mariadb."
  }
}

variable "size" {
  description = "Simulated database instance size."
  type        = string
  default     = "small"
  nullable    = false

  validation {
    condition     = contains(["small", "medium", "large", "xlarge"], var.size)
    error_message = "size must be one of: small, medium, large, xlarge."
  }
}

variable "backup_enabled" {
  description = "Whether automated backups are enabled."
  type        = bool
  default     = false
  nullable    = false
}

variable "read_replica" {
  description = "Whether to create a simulated read replica."
  type        = bool
  default     = false
  nullable    = false
}

variable "retention_days" {
  description = "Simulated backup retention period in days."
  type        = number
  default     = 7
  nullable    = false

  validation {
    condition     = var.retention_days >= 1 && var.retention_days <= 35
    error_message = "retention_days must be between 1 and 35."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet names the database is placed into (from the network module)."
  type        = list(string)
  default     = []
  nullable    = false
}
