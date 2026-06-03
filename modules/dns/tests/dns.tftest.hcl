# Tests for the dns module. Input-derived, so `command = plan` suffices.

run "internal_only_by_default" {
  command = plan

  variables {
    service_name = "transaction-worker"
    environment  = "dev"
    public       = false
  }

  assert {
    condition     = output.internal_hostname == "transaction-worker.dev.internal"
    error_message = "Internal hostname should follow <service>.<env>.internal."
  }

  assert {
    condition     = output.public_hostname == null
    error_message = "public_hostname should be null when the service is not public."
  }
}

run "public_record_when_public" {
  command = plan

  variables {
    service_name  = "merchant-portal"
    environment   = "prod"
    public        = true
    public_domain = "payments.example.com"
  }

  assert {
    condition     = output.public_hostname == "merchant-portal.payments.example.com"
    error_message = "Public hostname should follow <service>.<public_domain>."
  }

  assert {
    condition     = length(terraform_data.public_record) == 1
    error_message = "A public record should be created when public = true."
  }
}

# When service_target is empty, the records should fall back to resolving at the
# internal hostname (modules/dns/main.tf target local).
run "target_falls_back_to_internal_hostname" {
  command = plan

  variables {
    service_name   = "fraud-service"
    environment    = "dev"
    public         = false
    service_target = ""
  }

  assert {
    condition     = terraform_data.internal_record.input.target == "fraud-service.dev.internal"
    error_message = "With an empty service_target, the record target should fall back to the internal hostname."
  }
}

# An explicit target should be used verbatim.
run "explicit_target_is_used" {
  command = plan

  variables {
    service_name   = "fraud-service"
    environment    = "dev"
    public         = false
    service_target = "internal-lb-7"
  }

  assert {
    condition     = terraform_data.internal_record.input.target == "internal-lb-7"
    error_message = "An explicit service_target should be used as the record target."
  }
}
