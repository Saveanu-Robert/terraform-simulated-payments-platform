# The secrets module models secret REFERENCES, never secret values.
#
# Teaching point: Terraform state is not a secret store. Anything placed in a
# variable or resource argument is persisted to state in clear text. This module
# therefore only constructs paths/metadata pointing at where a secret WOULD live
# in a real secret manager. No secret material ever enters Terraform.

resource "terraform_data" "secret_reference" {
  for_each = toset(var.secret_names)

  input = {
    name        = each.key
    path        = "/${var.environment}/${var.service_name}/${each.key}"
    environment = var.environment
    service     = var.service_name
  }
}
