# Simulated Payments Platform (Terraform)

A realistic **mobile-money payments platform** modelled entirely in Terraform —
with **no real cloud infrastructure**. Every resource is a simulated
`terraform_data` (Terraform core), `random_*` (hashicorp/random), or
`local_file` (hashicorp/local). You run the real Terraform workflow
(`init` / `plan` / `apply` / `test` / `destroy`) and get real state, real module
composition, real guardrails, and generated artifacts — without an AWS/Azure/GCP
account, credentials, or cost.

> **Fake infrastructure, real Terraform.**

## What it simulates

The platform onboards eight services for a payments company across three
environments (`dev`, `staging`, `prod`):

| Service | Public | Database | Queue (DLQ) | Purpose |
|---|:---:|:---:|:---:|---|
| `payment-api` | ✅ | ✅ | ✅ | Accepts and validates payment requests |
| `merchant-portal` | ✅ | ✅ | — | Merchant-facing dashboard |
| `transaction-worker` | — | ✅ | ✅ | Processes async transaction jobs |
| `refund-api` | ✅ | ✅ | ✅ | Handles refunds |
| `settlement-worker` | — | ✅ | ✅ | Merchant settlement runs |
| `notification-service` | — | — | ✅ | Webhooks / SMS / email |
| `fraud-service` | — | ✅ | ✅ | Evaluates suspicious transactions |
| `reconciliation-service` | — | ✅ | — | Compares internal/external records |

Each service is composed from focused modules: a network, an IAM-style role,
secret references, a database (optional read replica), queues (with retry +
dead-letter), monitoring (dashboard + SLO + alerts), DNS records, and generated
deployment manifests.

## Requirements

- **Terraform >= 1.10** (verified on 1.15.5 — see `.terraform-version`)
- No cloud credentials, no paid accounts.
- Optional dev tooling: `tflint`, `pre-commit`.

## Repository layout

```
modules/                 # 10 reusable, single-responsibility simulated modules
  naming/                #   canonical names + standard tags (pure computation)
  network/               #   network + subnets per zone (uses random)
  database/              #   primary DB + optional replica, prod guardrails
  queue/                 #   main + retry + dead-letter queues
  iam/                   #   least-privilege role from capability flags
  secrets/               #   secret REFERENCES only (never values)
  service/               #   the deployable service + lifecycle preconditions
  monitoring/            #   dashboard, SLO, alert map
  dns/                   #   internal + optional public records
  manifest/              #   generated local JSON artifacts (uses local_file)
environments/            # one root module (composition) per environment
  dev/  staging/  prod/  #   each: *.tf + terraform.tfvars + tests/
generated/               # JSON artifacts written by `apply` (gitignored)
.github/workflows/       # terraform.yml (CI on push/PR) + e2e-demo.yml (one-click manual demo)
```

Each module is `main.tf` / `variables.tf` / `outputs.tf` / `versions.tf` plus a
`tests/<module>.tftest.hcl`. Modules are generic; everything
environment-specific lives in each environment's `terraform.tfvars`.

## How to use

Pick an environment and run the standard workflow:

```bash
cd environments/dev      # or staging / prod

terraform init           # installs random + local providers, local backend
terraform plan           # preview the simulated platform
terraform apply          # create simulated resources + write generated/<env>/*

terraform state list     # inspect the simulated objects in state
terraform output         # services, databases, queues, dns_records, iam_roles, ...

terraform destroy        # tear everything down (removes generated files too)
```

After `apply`, generated manifests appear under `generated/<env>/<service>/`:

```
generated/dev/payment-api/service.json
generated/dev/payment-api/deployment.json
generated/dev/payment-api/alerts.json
generated/dev/payment-api/dependencies.json
```

### Run the tests

Native `terraform test` covers each module and environment (positive,
negative/guardrail, and mock-provider cases):

```bash
# one module
cd modules/service && terraform init -backend=false && terraform test

# one environment
cd environments/prod && terraform init -backend=false && terraform test
```

### Format and lint

```bash
terraform fmt -recursive
tflint --recursive --config "$PWD/.tflint.hcl"
```

### One-click end-to-end demo (no local setup)

Want to watch the whole platform stand up without installing anything? In
GitHub, open **Actions → "E2E Demo (manual)" → Run workflow** (leave
`environment` set to `all`, then press the button). It runs the full lifecycle
for each environment — `apply` the entire stack, print outputs/state/generated
manifests, demonstrate drift detection, then `destroy` — and posts a summary
table to the run page. All simulated; no credentials, no cost.

## The application model

A single typed `applications` map (in `environments/<env>/variables.tf`) drives
the whole platform; `optional()` defaults keep each entry terse. Adding or
changing a service is a `terraform.tfvars` edit — no module changes needed:

```hcl
applications = {
  payment-api = {
    owner    = "payments-team"
    image    = "payment-api:1.4.0"
    replicas = 3
    public   = true

    database    = { enabled = true, engine = "postgres", size = "large", backup_enabled = true, read_replica = true }
    queue       = { enabled = true, dead_letter_queue_enabled = true }
    monitoring  = { enabled = true, alerts = { high_error_rate = { threshold = 0.01, severity = "critical" } } }
    permissions = { database_read = true, database_write = true, queue_publish = true, secrets_read = true }
    secrets     = ["database-password", "api-token"]
  }
}
```

## Guardrails

Governance is layered (see `modules/*/variables.tf` and `main.tf`):

- **Variable validation** — environment ∈ {dev,staging,prod}; service names
  lowercase kebab-case; replicas ≥ 1; ≤ 8 zones; valid CIDR/engine/size/severity.
- **Lifecycle preconditions** — production services need ≥ 2 replicas;
  production databases require backups and may not be `small`.
- **`check` blocks** (advisory) — production services should have monitoring;
  public production services should define alerts.

`dev` is permissive (single replicas, optional backups); `staging` is
production-like (≥ 2 replicas, backups on, three zones); `prod` enforces the
strictest rules.

## Notes

- **Local state is intentional.** This is a simulation with no real
  infrastructure, so state is local and easy to inspect. A real deployment would
  use a remote backend (S3 + native lock file on TF 1.10+, Azure Storage, GCS,
  or Terraform Cloud) for locking, encryption, and collaboration.
- **No secrets in state.** The `secrets` module models reference *paths* only —
  never secret values — because Terraform state is not a secret store.
- **CI** (`.github/workflows/terraform.yml`) runs `fmt`, `tflint`, `validate`,
  `test`, and `plan` for all modules and environments on every push/PR.
- **One-click demo** (`.github/workflows/e2e-demo.yml`) is a manually-triggered
  workflow (Actions → *E2E Demo (manual)* → *Run workflow*) that applies the full
  platform, prints outputs/state/generated manifests, demonstrates drift
  detection, and destroys it — all simulated, end to end.
