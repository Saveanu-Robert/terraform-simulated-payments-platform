# Tests for the service module.
#
# Positive assertions read `.input` (known at plan) so they can run with the
# fast `command = plan`. Guardrail (precondition) failures are also evaluated
# at plan, so negative tests use `command = plan` and target the resource
# address in `expect_failures`.

run "valid_dev_service" {
  command = plan

  variables {
    name         = "payment-api"
    environment  = "dev"
    image        = "payment-api:1.0.0"
    replicas     = 1
    public       = true
    owner        = "payments-team"
    cost_center  = "payments"
    dependencies = []
  }

  assert {
    condition     = terraform_data.service.input.name == "payment-api"
    error_message = "Service name should be preserved in the resource input."
  }

  assert {
    condition     = output.service.replicas == 1
    error_message = "Service summary output should reflect the requested replica count."
  }
}

# Apply-mode test: `.output` is only known after apply. This also exercises the
# postcondition (self.output.name == var.name).
run "output_known_after_apply" {
  command = apply

  variables {
    name         = "payment-api"
    environment  = "dev"
    image        = "payment-api:1.0.0"
    replicas     = 1
    public       = true
    owner        = "payments-team"
    cost_center  = "payments"
    dependencies = []
  }

  assert {
    condition     = terraform_data.service.output.name == "payment-api"
    error_message = "After apply, the terraform_data output should mirror the input name."
  }
}

# Negative test: production requires >= 2 replicas. The precondition is attached
# to terraform_data.service, so that is the address that fails.
run "prod_service_requires_two_replicas" {
  command = plan

  variables {
    name         = "payment-api"
    environment  = "prod"
    image        = "payment-api:1.0.0"
    replicas     = 1
    public       = true
    owner        = "payments-team"
    cost_center  = "payments"
    dependencies = []
  }

  expect_failures = [
    terraform_data.service,
  ]
}

# Negative test: empty owner must fail variable validation (var address).
run "service_requires_owner" {
  command = plan

  variables {
    name         = "payment-api"
    environment  = "dev"
    image        = "payment-api:1.0.0"
    replicas     = 1
    public       = false
    owner        = "   "
    cost_center  = "payments"
    dependencies = []
  }

  expect_failures = [
    var.owner,
  ]
}
