# Tests for the monitoring module. Input-derived, so `command = plan` suffices.

run "creates_dashboard_and_alerts" {
  command = plan

  variables {
    service_name = "payment-api"
    environment  = "prod"
    alerts = {
      high_error_rate = {
        threshold = 0.05
        severity  = "critical"
      }
      high_latency = {
        threshold = 500
        severity  = "warning"
      }
    }
  }

  assert {
    condition     = output.dashboard_name == "prod-payment-api-dashboard"
    error_message = "Dashboard name should follow <env>-<service>-dashboard."
  }

  assert {
    condition     = output.alert_names == tolist(["high_error_rate", "high_latency"])
    error_message = "Alert names should be the sorted keys of the alerts map."
  }
}

run "severity_defaults_to_warning" {
  command = plan

  variables {
    service_name = "refund-api"
    environment  = "dev"
    alerts = {
      basic = {
        threshold = 0.1
      }
    }
  }

  assert {
    condition     = terraform_data.alerts["basic"].input.severity == "warning"
    error_message = "Alert severity should default to warning when omitted."
  }
}

# Negative test: invalid severity fails validation.
run "rejects_invalid_severity" {
  command = plan

  variables {
    service_name = "payment-api"
    environment  = "dev"
    alerts = {
      bad = {
        threshold = 1
        severity  = "emergency"
      }
    }
  }

  expect_failures = [
    var.alerts,
  ]
}
