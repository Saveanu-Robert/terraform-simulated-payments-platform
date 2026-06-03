variable "service_name" {
  description = "Service the generated manifests describe."
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

variable "output_root" {
  description = "Absolute or root-relative directory under which manifests are written. Injected by the caller so this module never hardcodes a relative depth."
  type        = string

  validation {
    condition     = length(trimspace(var.output_root)) > 0
    error_message = "output_root must be a non-empty path."
  }
}

variable "owner" {
  description = "Owning team, recorded in the service manifest."
  type        = string
}

variable "image" {
  description = "Container image reference."
  type        = string
}

variable "replicas" {
  description = "Replica count recorded in the deployment manifest."
  type        = number
}

variable "public" {
  description = "Whether the service is public."
  type        = bool
  default     = false
  nullable    = false
}

variable "dependencies" {
  description = "Capability names this service depends on."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "alerts" {
  description = "Map of alert name => definition, recorded in the alerts manifest."
  type = map(object({
    threshold = number
    severity  = optional(string, "warning")
  }))
  default  = {}
  nullable = false
}

variable "rollout_strategy" {
  description = "Rollout strategy recorded in the deployment manifest."
  type        = string
  default     = "rolling"
  nullable    = false
}

variable "tags" {
  description = "Standard tags (e.g. from the naming module) recorded in the service manifest."
  type        = map(string)
  default     = {}
  nullable    = false
}
