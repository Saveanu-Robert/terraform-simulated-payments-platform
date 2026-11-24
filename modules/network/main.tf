# The network module simulates a cloud network layer: one network, a set of
# public + private subnets (one per zone), and a service-discovery namespace.
#
# Concepts taught here:
#   - the `random` provider (generated, unknown-at-plan values)
#   - `for_each` over a set to create named, address-stable subnets
#   - building collection outputs with `for` expressions (NOT splat, which only
#     works on count/list resources)

# A generated suffix gives the network a realistic, unique-looking identifier.
# random_id is UNKNOWN AT PLAN, so anything that interpolates it must be tested
# with `command = apply` (or with a mock_provider — see the network tests).
resource "random_id" "network_suffix" {
  byte_length = 3

  keepers = {
    environment = var.environment
  }
}

locals {
  network_name = "${var.environment}-payments-network-${random_id.network_suffix.hex}"
}

resource "terraform_data" "network" {
  input = {
    name        = local.network_name
    cidr_block  = var.cidr_block
    environment = var.environment
  }
}

resource "terraform_data" "private_subnets" {
  for_each = toset(var.zones)

  input = {
    name        = "${var.environment}-private-${each.key}"
    zone        = each.key
    type        = "private"
    cidr_block  = cidrsubnet(var.cidr_block, 4, index(var.zones, each.key))
    network     = terraform_data.network.input.name
    environment = var.environment
  }
}

resource "terraform_data" "public_subnets" {
  for_each = toset(var.zones)

  input = {
    name        = "${var.environment}-public-${each.key}"
    zone        = each.key
    type        = "public"
    cidr_block  = cidrsubnet(var.cidr_block, 4, index(var.zones, each.key) + length(var.zones))
    network     = terraform_data.network.input.name
    environment = var.environment
  }
}

resource "terraform_data" "service_discovery_namespace" {
  input = {
    name        = "${var.environment}.payments.internal"
    environment = var.environment
  }
}
