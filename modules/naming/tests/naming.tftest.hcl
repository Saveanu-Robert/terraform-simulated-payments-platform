# Tests for the naming module.
# Everything here is input-derived (no random, no terraform_data.output), so
# `command = plan` is correct and fast for the positive assertions.

run "produces_standard_name" {
  command = plan

  variables {
    organization = "pawapay"
    environment  = "dev"
    service_name = "payment-api"
  }

  assert {
    condition     = output.standard_name == "pawapay-dev-payment-api"
    error_message = "standard_name should join organization, environment, and service_name with hyphens."
  }

  assert {
    condition     = output.tags["managed_by"] == "terraform" && output.tags["simulated"] == "true"
    error_message = "Standard tags must mark resources as terraform-managed and simulated."
  }
}

run "merges_extra_tags" {
  command = plan

  variables {
    organization = "pawapay"
    environment  = "prod"
    service_name = "refund-api"
    extra_tags = {
      cost_center = "payments"
    }
  }

  assert {
    condition     = output.tags["cost_center"] == "payments"
    error_message = "extra_tags should be merged into the standard tag set."
  }
}

# Reserved standard tags must win over colliding extra_tags. This passes a
# colliding key on purpose to actually exercise the invariant.
run "reserved_tags_cannot_be_overridden" {
  command = plan

  variables {
    organization = "pawapay"
    environment  = "prod"
    service_name = "payment-api"
    extra_tags = {
      environment = "HACKED"
      managed_by  = "someone-else"
      team        = "payments"
    }
  }

  assert {
    condition     = output.tags["environment"] == "prod"
    error_message = "Reserved 'environment' tag must not be overridable by extra_tags."
  }

  assert {
    condition     = output.tags["managed_by"] == "terraform"
    error_message = "Reserved 'managed_by' tag must not be overridable by extra_tags."
  }

  assert {
    condition     = output.tags["team"] == "payments"
    error_message = "Non-reserved extra_tags should still be merged in."
  }
}

# Negative test: an invalid environment must fail variable validation.
# The failing address is the VARIABLE, not a resource.
run "rejects_invalid_environment" {
  command = plan

  variables {
    organization = "pawapay"
    environment  = "production"
    service_name = "payment-api"
  }

  expect_failures = [
    var.environment,
  ]
}

# Negative test: an upper-case / underscored service name must fail validation.
run "rejects_invalid_service_name" {
  command = plan

  variables {
    organization = "pawapay"
    environment  = "dev"
    service_name = "Payment_API"
  }

  expect_failures = [
    var.service_name,
  ]
}
