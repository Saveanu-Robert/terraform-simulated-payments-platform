# The manifest module generates visible local artifacts (JSON files) that
# represent what WOULD be deployed. These files make Terraform's output tangible
# without any cloud access, and they make drift visible: edit a generated file,
# run `plan`, and Terraform proposes restoring the declared content.
#
# `output_root` is injected by the caller (the environment root module) so this
# module never hardcodes a fragile relative path like ../../.

locals {
  service_dir = "${var.output_root}/${var.environment}/${var.service_name}"

  service_content = jsonencode({
    service      = var.service_name
    environment  = var.environment
    owner        = var.owner
    image        = var.image
    public       = var.public
    dependencies = var.dependencies
    tags         = var.tags
  })

  deployment_content = jsonencode({
    service     = var.service_name
    environment = var.environment
    replicas    = var.replicas
    image       = var.image
    strategy    = var.rollout_strategy
  })

  alerts_content = jsonencode({
    service     = var.service_name
    environment = var.environment
    alerts      = var.alerts
  })

  dependencies_content = jsonencode({
    service      = var.service_name
    environment  = var.environment
    dependencies = var.dependencies
  })
}

resource "local_file" "service_manifest" {
  filename = "${local.service_dir}/service.json"
  content  = local.service_content
}

resource "local_file" "deployment_manifest" {
  filename = "${local.service_dir}/deployment.json"
  content  = local.deployment_content
}

resource "local_file" "alerts_manifest" {
  filename = "${local.service_dir}/alerts.json"
  content  = local.alerts_content
}

resource "local_file" "dependencies_manifest" {
  filename = "${local.service_dir}/dependencies.json"
  content  = local.dependencies_content
}
