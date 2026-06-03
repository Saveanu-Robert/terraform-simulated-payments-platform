variable "name" {
  description = "Logical service name (lowercase kebab-case)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,40}$", var.name))
    error_message = "Service name must be lowercase kebab-case, start with a letter, and be 3-41 characters."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "image" {
  description = "Container image reference for the simulated service (e.g. payment-api:1.0.0)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._/-]*:[a-zA-Z0-9._-]+$", var.image))
    error_message = "Image must be of the form <name>:<tag>, e.g. payment-api:1.0.0."
  }
}

variable "replicas" {
  description = "Desired replica count for the simulated service."
  type        = number

  validation {
    condition     = var.replicas >= 1 && floor(var.replicas) == var.replicas
    error_message = "Replicas must be a whole number >= 1."
  }
}

variable "public" {
  description = "Whether the service is exposed publicly."
  type        = bool
  default     = false
  nullable    = false
}

variable "owner" {
  description = "Owning team for the service. Required metadata for governance."
  type        = string

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "Every service must declare a non-empty owner."
  }
}

variable "cost_center" {
  description = "Cost center used for chargeback/showback metadata."
  type        = string
  default     = "unallocated"
  nullable    = false
}

variable "dependencies" {
  description = "Names of platform capabilities (databases, queues, ...) this service depends on."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "health_check_path" {
  description = "HTTP path used by the simulated health check."
  type        = string
  default     = "/healthz"
  nullable    = false
}

variable "rollout_strategy" {
  description = "Simulated rollout strategy for the service."
  type        = string
  default     = "rolling"
  nullable    = false

  validation {
    condition     = contains(["rolling", "blue-green", "canary", "recreate"], var.rollout_strategy)
    error_message = "rollout_strategy must be one of: rolling, blue-green, canary, recreate."
  }
}
