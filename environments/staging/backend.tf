# Local backend — this is a simulation with no real infrastructure, so state is
# intentionally local and easy to inspect (open terraform.tfstate directly).
#
# In a real team/production setup you would use a remote backend (S3 + native
# lock file on TF 1.10+, Azure Storage, GCS, or Terraform Cloud) for locking,
# encryption, versioning, and safe collaboration.
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
