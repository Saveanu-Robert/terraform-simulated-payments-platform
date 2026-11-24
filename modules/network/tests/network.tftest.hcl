# Tests for the network module.
#
# The network name interpolates random_id, which is UNKNOWN AT PLAN. So:
#   - assertions about subnet names (input-derived) can use `command = plan`
#   - assertions about network_name require `command = apply`
#   - the mock_provider run shows how mocking random_id makes the generated
#     value deterministic and therefore knowable at plan time.

run "creates_one_subnet_pair_per_zone" {
  command = plan

  variables {
    environment = "dev"
    cidr_block  = "10.10.0.0/16"
    zones       = ["zone-a", "zone-b"]
  }

  assert {
    condition     = length(output.private_subnet_ids) == 2
    error_message = "There should be one private subnet per zone."
  }

  assert {
    condition     = contains(output.private_subnet_ids, "dev-private-zone-a")
    error_message = "Private subnet names should follow the <env>-private-<zone> convention."
  }

  assert {
    condition     = length(output.public_subnet_ids) == 2
    error_message = "There should be one public subnet per zone."
  }
}

run "network_name_known_after_apply" {
  command = apply

  variables {
    environment = "staging"
    cidr_block  = "10.20.0.0/16"
    zones       = ["zone-a"]
  }

  assert {
    condition     = startswith(output.network_name, "staging-payments-network-")
    error_message = "Network name should be prefixed with <env>-payments-network-."
  }
}

# Negative test: an invalid CIDR must fail variable validation.
run "rejects_invalid_cidr" {
  command = plan

  variables {
    environment = "dev"
    cidr_block  = "not-a-cidr"
    zones       = ["zone-a"]
  }

  expect_failures = [
    var.cidr_block,
  ]
}

# Negative test: more than 8 zones would overflow subnet addressing and must be
# rejected by validation (before cidrsubnet can error at plan time).
run "rejects_too_many_zones" {
  command = plan

  variables {
    environment = "dev"
    cidr_block  = "10.10.0.0/16"
    zones       = ["z1", "z2", "z3", "z4", "z5", "z6", "z7", "z8", "z9"]
  }

  expect_failures = [
    var.zones,
  ]
}

# --- Mocking lesson -------------------------------------------------------
# By mocking the `random` provider we pin random_id.hex to a known value.
# That turns network_name into a plan-time-known value, so we can assert its
# exact content under `command = plan` (no apply needed). This is the honest,
# concrete way to teach mocking in a project that uses only built-in providers.
mock_provider "random" {
  mock_resource "random_id" {
    defaults = {
      hex = "abc123"
      id  = "abc123"
    }
  }
}

run "network_name_is_deterministic_with_mocked_random" {
  command = plan

  variables {
    environment = "dev"
    cidr_block  = "10.10.0.0/16"
    zones       = ["zone-a"]
  }

  assert {
    condition     = output.network_name == "dev-payments-network-abc123"
    error_message = "With random_id mocked to abc123, the network name should be fully known at plan time."
  }
}
