variable "organization" {
  description = "Organization or platform prefix used to namespace every simulated resource."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.organization))
    error_message = "Organization must be lowercase kebab-case, start with a letter, and be 2-31 characters."
  }
}

variable "environment" {
  description = "Deployment environment for the simulated platform."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "service_name" {
  description = "Logical service name (lowercase kebab-case)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,40}$", var.service_name))
    error_message = "Service name must be lowercase kebab-case, start with a letter, and be 3-41 characters."
  }
}

variable "extra_tags" {
  description = "Optional additional tags merged into the standard tag set."
  type        = map(string)
  default     = {}
  nullable    = false
}
