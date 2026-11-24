# The monitoring module simulates observability resources: a dashboard, an
# availability SLO, and a configurable set of alerts (a map of objects).

locals {
  dashboard_name = "${var.environment}-${var.service_name}-dashboard"
}

resource "terraform_data" "dashboard" {
  input = {
    name        = local.dashboard_name
    service     = var.service_name
    environment = var.environment
    panels = [
      "request_rate",
      "latency_p95",
      "error_rate",
      "queue_depth",
    ]
  }
}

resource "terraform_data" "slo" {
  input = {
    service      = var.service_name
    environment  = var.environment
    availability = var.slo_availability
  }
}

resource "terraform_data" "alerts" {
  for_each = var.alerts

  input = {
    name        = each.key
    service     = var.service_name
    environment = var.environment
    threshold   = each.value.threshold
    severity    = each.value.severity
  }
}
