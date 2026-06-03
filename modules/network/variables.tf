variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "cidr_block" {
  description = "Simulated CIDR block for the payments network."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid CIDR, e.g. 10.10.0.0/16."
  }
}

variable "zones" {
  description = "Availability zones to spread simulated subnets across."
  type        = list(string)

  validation {
    condition     = length(var.zones) >= 1
    error_message = "At least one zone is required."
  }

  validation {
    condition     = length(var.zones) == length(distinct(var.zones))
    error_message = "Zones must be unique."
  }

  # Subnets are carved with cidrsubnet(cidr, 4, ...) and public subnets use
  # indices length(zones)..2*length(zones)-1. With 4 new bits the maximum valid
  # index is 15, so more than 8 zones would overflow at plan time. Guard it.
  validation {
    condition     = length(var.zones) <= 8
    error_message = "A maximum of 8 zones is supported (subnet addressing uses 4 bits)."
  }
}
