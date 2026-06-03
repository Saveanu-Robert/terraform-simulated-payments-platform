# Tests for the secrets module. Input-derived, so `command = plan` suffices.

run "builds_reference_paths" {
  command = plan

  variables {
    service_name = "payment-api"
    environment  = "prod"
    secret_names = ["database-password", "api-token"]
  }

  assert {
    condition     = output.secret_paths["database-password"] == "/prod/payment-api/database-password"
    error_message = "Secret paths should follow /<env>/<service>/<name>."
  }

  assert {
    condition     = length(output.secret_paths) == 2
    error_message = "There should be one reference per secret name."
  }
}

run "empty_when_no_secrets" {
  command = plan

  variables {
    service_name = "merchant-portal"
    environment  = "dev"
    secret_names = []
  }

  assert {
    condition     = length(output.secret_paths) == 0
    error_message = "No secret names should produce no references."
  }
}

# Negative test: an upper-cased secret name fails validation.
run "rejects_invalid_secret_name" {
  command = plan

  variables {
    service_name = "payment-api"
    environment  = "dev"
    secret_names = ["Database_Password"]
  }

  expect_failures = [
    var.secret_names,
  ]
}
