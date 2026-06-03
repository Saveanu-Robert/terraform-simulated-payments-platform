# Environment root module: composes the reusable modules into a full simulated
# payments platform driven entirely by the `applications` map.
#
# Pattern highlights:
#   - one shared network for the environment
#   - per-application modules created with for_each, filtered for optional
#     capabilities (database/queue/monitoring) using map comprehensions
#   - implicit dependencies: service depends on database/queue because it
#     references their outputs through local.service_dependencies
#   - check blocks: advisory, environment-wide assertions

# Standard names + tags for every application, centralized in one module.
module "naming" {
  for_each = var.applications

  source = "../../modules/naming"

  organization = var.organization
  environment  = var.environment
  service_name = each.key
  extra_tags = {
    owner       = each.value.owner
    cost_center = each.value.cost_center
  }
}

module "network" {
  source = "../../modules/network"

  environment = var.environment
  cidr_block  = var.network.cidr_block
  zones       = var.network.zones
}

module "database" {
  for_each = {
    for name, app in var.applications : name => app
    if app.database.enabled
  }

  source = "../../modules/database"

  name               = each.key
  environment        = var.environment
  engine             = each.value.database.engine
  size               = each.value.database.size
  backup_enabled     = each.value.database.backup_enabled
  read_replica       = each.value.database.read_replica
  private_subnet_ids = module.network.private_subnet_ids
}

module "queue" {
  for_each = {
    for name, app in var.applications : name => app
    if app.queue.enabled
  }

  source = "../../modules/queue"

  name                       = each.key
  environment                = var.environment
  dead_letter_queue_enabled  = each.value.queue.dead_letter_queue_enabled
  retry_queue_enabled        = each.value.queue.retry_queue_enabled
  message_retention_seconds  = each.value.queue.message_retention_seconds
  visibility_timeout_seconds = each.value.queue.visibility_timeout_seconds
}

module "iam" {
  for_each = var.applications

  source = "../../modules/iam"

  service_name = each.key
  environment  = var.environment
  permissions  = each.value.permissions
}

module "secrets" {
  for_each = var.applications

  source = "../../modules/secrets"

  service_name = each.key
  environment  = var.environment
  secret_names = each.value.secrets
}

# Build each service's dependency list from the modules that were actually
# created. The `if app.database.enabled` guard ensures we only dereference
# module.database[name] when that instance exists.
locals {
  service_dependencies = {
    for name, app in var.applications : name => compact([
      app.database.enabled ? module.database[name].database_name : "",
      app.queue.enabled ? module.queue[name].queue_name : "",
    ])
  }
}

module "service" {
  for_each = var.applications

  source = "../../modules/service"

  name             = each.key
  environment      = var.environment
  image            = each.value.image
  replicas         = each.value.replicas
  public           = each.value.public
  owner            = each.value.owner
  cost_center      = each.value.cost_center
  dependencies     = local.service_dependencies[each.key]
  rollout_strategy = each.value.rollout_strategy
}

module "monitoring" {
  for_each = {
    for name, app in var.applications : name => app
    if app.monitoring.enabled
  }

  source = "../../modules/monitoring"

  service_name = each.key
  environment  = var.environment
  alerts       = each.value.monitoring.alerts
}

module "dns" {
  for_each = var.applications

  source = "../../modules/dns"

  service_name   = each.key
  environment    = var.environment
  public         = each.value.public
  public_domain  = var.public_domain
  service_target = module.service[each.key].service_name
}

module "manifest" {
  for_each = var.applications

  source = "../../modules/manifest"

  service_name = each.key
  environment  = var.environment
  # Repo-relative target: <repo>/generated. The root module owns this path so
  # the manifest module never hardcodes a relative depth of its own.
  output_root      = "${path.root}/../../generated"
  owner            = each.value.owner
  image            = each.value.image
  replicas         = each.value.replicas
  public           = each.value.public
  dependencies     = local.service_dependencies[each.key]
  alerts           = each.value.monitoring.enabled ? each.value.monitoring.alerts : {}
  rollout_strategy = each.value.rollout_strategy
  tags             = module.naming[each.key].tags
}

# --- Advisory checks (warn, do not block) ---------------------------------
check "production_services_have_monitoring" {
  assert {
    condition = var.environment != "prod" || alltrue([
      for app in values(var.applications) : app.monitoring.enabled
    ])
    error_message = "All production services should have monitoring enabled."
  }
}

check "public_production_services_have_alerts" {
  assert {
    condition = var.environment != "prod" || alltrue([
      for app in values(var.applications) :
      length(app.monitoring.alerts) > 0 if app.public
    ])
    error_message = "Public production services should define at least one alert."
  }
}
