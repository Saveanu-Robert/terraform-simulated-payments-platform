variable "service_name" {
  description = "Service the DNS records point at."
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

variable "public" {
  description = "Whether to create a public DNS record in addition to the internal one."
  type        = bool
  default     = false
  nullable    = false
}

variable "public_domain" {
  description = "Public domain used for the public hostname (when public = true)."
  type        = string
  default     = "payments.example.com"
  nullable    = false
}

variable "service_target" {
  description = "Simulated target the DNS records resolve to (e.g. an internal load balancer name)."
  type        = string
  default     = ""
  nullable    = false
}
