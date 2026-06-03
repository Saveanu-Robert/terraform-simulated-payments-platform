# The service module simulates a deployable application service.
#
# It uses `terraform_data` (a built-in Terraform resource that stores values in
# state and participates in the resource lifecycle without creating any real
# infrastructure). The lifecycle preconditions are the heart of this module:
# they encode production-readiness guardrails that fail `plan`/`apply` when an
# environment's rules are violated.
#
# Teaching note: `terraform_data.service.output` mirrors `input`, but `output`
# is only KNOWN AFTER APPLY. References that must work at plan time should read
# `.input`; the `postcondition` below runs after apply, where `output` is known.

resource "terraform_data" "service" {
  input = {
    name              = var.name
    environment       = var.environment
    image             = var.image
    replicas          = var.replicas
    public            = var.public
    owner             = var.owner
    cost_center       = var.cost_center
    dependencies      = var.dependencies
    health_check_path = var.health_check_path
    rollout_strategy  = var.rollout_strategy
  }

  lifecycle {
    # Resource-rule guardrail (precondition): a cross-field rule that depends on
    # the environment. Non-empty owner is enforced one layer up by var.owner's
    # validation, so it is intentionally NOT duplicated here.
    precondition {
      condition     = var.environment != "prod" || var.replicas >= 2
      error_message = "Production services must run at least 2 replicas (got ${var.replicas} for ${var.name})."
    }

    # Demonstrates a postcondition: validates an assumption about the resource's
    # own output after it is known (post-apply).
    postcondition {
      condition     = self.output.name == var.name
      error_message = "Service output name must match the requested input name."
    }
  }
}
