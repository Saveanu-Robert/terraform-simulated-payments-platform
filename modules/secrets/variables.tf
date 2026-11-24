variable "service_name" {
  description = "Service the secret references belong to."
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

variable "secret_names" {
  description = "Logical secret names to model as references. NEVER pass real secret values here — this module stores only metadata/paths, not secret material."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for s in var.secret_names : can(regex("^[a-z][a-z0-9-]{1,60}$", s))])
    error_message = "Secret names must be lowercase kebab-case (letters, digits, hyphens)."
  }
}
