# Tests for the manifest module.
#
# local_file resources actually write to disk, so assertions about the files
# require `command = apply`. The test writes into a module-local scratch
# directory; Terraform removes the files again during teardown.

run "generates_four_manifests" {
  command = apply

  variables {
    service_name = "payment-api"
    environment  = "dev"
    output_root  = "./.tftest-generated"
    owner        = "payments-team"
    image        = "payment-api:1.0.0"
    replicas     = 2
    public       = true
    dependencies = ["dev-payment-api-db", "dev-payment-api-queue"]
    alerts = {
      high_error_rate = {
        threshold = 0.05
        severity  = "critical"
      }
    }
  }

  assert {
    condition     = length(output.manifest_paths) == 4
    error_message = "The module should generate exactly four manifest files."
  }

  assert {
    condition     = output.service_dir == "./.tftest-generated/dev/payment-api"
    error_message = "Manifests should be written under <output_root>/<env>/<service>."
  }

  # local_file exposes content_md5/content; assert the rendered service manifest
  # contains the owner we passed in.
  assert {
    condition     = strcontains(local_file.service_manifest.content, "payments-team")
    error_message = "The service manifest should record the owner."
  }

  assert {
    condition     = strcontains(local_file.deployment_manifest.content, "\"replicas\":2")
    error_message = "The deployment manifest should record the replica count."
  }
}
