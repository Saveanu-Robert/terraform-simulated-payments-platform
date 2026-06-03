# TFLint configuration for the simulated payments platform.
# This project uses only the built-in `terraform_data` resource plus the
# hashicorp/random and hashicorp/local providers, so we rely on the bundled
# `terraform` ruleset rather than a cloud-specific plugin.

config {
  # Inspect modules called from the configuration too.
  call_module_type = "all"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Enforce naming + documentation discipline that this teaching repo cares about.
rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}
