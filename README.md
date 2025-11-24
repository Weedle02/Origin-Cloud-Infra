# Azure Platform Starter Kit

Opinionated reference implementation for standing up a multi-environment Azure landing zone with automated policy enforcement, subscription factory, centralized diagnostics, and CI/CD built for GitHub Actions. The project is structured so you can start from a minimal set of configuration files and grow into a production-ready platform covering dev/test/prod.

## Repository layout

```
.
├── infra
│   ├── bicep
│   │   ├── main.bicep
│   │   └── modules
│   │       ├── diagnostics
│   │       │   └── diagnostics.bicep
│   │       ├── management-groups
│   │       │   └── managementGroups.bicep
│   │       ├── policies
│   │       │   └── baselinePolicies.bicep
│   │       └── subscription-factory
│   │           └── subscriptionFactory.bicep
│   └── terraform
│       ├── main.tf
│       └── modules
│           ├── diagnostics
│           │   └── main.tf
│           ├── management_groups
│           │   └── main.tf
│           ├── policies
│           │   └── main.tf
│           └── subscription_factory
│               └── main.tf
├── platform
│   └── config
│       └── platform.yaml
├── policies
│   └── assignments
│       └── baseline.json
├── scripts
│   └── validate.sh
├── tests
│   └── python
│       └── test_platform_scaffolding.py
└── .github
    └── workflows
        └── terraform-plan-apply.yml
```

## Core concepts

- **Management group & subscription factory**: Declarative factory that builds your management group hierarchy (root, platform, landing zones, sandbox) and provisions subscriptions from a YAML manifest, automatically attaching them to the right management group.
- **Policy-first posture**: Baseline policy assignments for allowed SKUs/locations, required tags, diagnostic forwarding, and backup defaults. The `policies/assignments` folder houses the JSON used for assignments or policy set definitions.
- **Central diagnostics & cost**: Shared Log Analytics workspace, storage, and Sentinel onboarding. Budgets and cost alerts are expected per subscription.
- **Pipelines**: GitHub Actions workflow uses OIDC to Azure for secretless auth, runs lint/security checks, plans on pull requests, and applies on merge.
- **Tests**: Terratest or Python smoke tests validate policy assignments, diagnostic settings, and required tags once infrastructure is deployed.

## Getting started

1. **Install prerequisites**
   - Azure CLI (with `az login` configured for your tenant)
   - Terraform >= 1.6 and/or Azure Bicep CLI
   - GitHub OIDC federation configured in your Azure tenant (workload identity federation for your repo)
2. **Clone and review**
   - Update `platform/config/platform.yaml` with your tenant ID, root management group ID, and subscription plan.
   - Adjust policy assignments in `policies/assignments/baseline.json` to reflect your tag keys, allowed SKUs, and location strategy.
3. **Choose IaC flavor**
   - Use `infra/terraform` or `infra/bicep`. Both paths aim to produce the same logical platform layout.
4. **Plan and apply**
   - Run `scripts/validate.sh` locally to lint and format before raising a pull request.
   - Open a PR; GitHub Actions will run `terraform plan` (or `bicep build`/`what-if` if you adapt the workflow). On merge to `main`, the workflow will perform `terraform apply` using OIDC.

## Configuration

`platform/config/platform.yaml` is the single source of truth for your management group hierarchy and subscription catalog.

- **managementGroups**: Defines the hierarchy and any default policy sets or tags.
- **subscriptions**: Lists subscriptions to create or import, with their target management group and default tags.

Example (included in the repo):

```yaml
tenantId: 00000000-0000-0000-0000-000000000000
rootManagementGroupId: contoso-root
managementGroups:
  - name: platform
    displayName: Platform
    parent: contoso-root
  - name: landing-zones
    displayName: Landing Zones
    parent: contoso-root
  - name: sandbox
    displayName: Sandbox
    parent: contoso-root
subscriptions:
  - alias: platform-shared
    displayName: Platform Shared Services
    managementGroup: platform
    tags:
      env: platform
      owner: platform-team
  - alias: dev-apps
    displayName: Dev Apps
    managementGroup: landing-zones
    tags:
      env: dev
      owner: app-team
```

## Pipelines

The included GitHub Actions workflow (`.github/workflows/terraform-plan-apply.yml`) demonstrates:

- OIDC-based authentication to Azure using a federated credential (no secrets required).
- `terraform fmt` and `terraform validate` for hygiene.
- `tfsec` as the default security scanner; swap for `checkov` if preferred.
- `terraform plan` on pull requests.
- `terraform apply` gated to the `main` branch after approval and plan output.

Before using the workflow, set the following repository-level GitHub Secrets/Variables:

- `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` (from your workload identity app registration).
- Optional: `TF_VERSION` to pin a Terraform version.

## Testing strategy

- **Infrastructure validation**: Terratest (Go) or Python tests in `tests/python` can be expanded to verify that required policy assignments, diagnostic settings, and tags exist across resources.
- **Policy linting**: Use `az policy definition list`/`policy assignment list` in scripts to cross-check the contents of `policies/assignments/baseline.json` against deployed state.
- **Smoke tests**: Add quick checks that confirm log forwarding to Log Analytics, budget alerts per subscription, and backup settings on critical services (Key Vault, storage, VMs).

## Extending the starter kit

- Add environment overlays (e.g., `platform/config/platform.dev.yaml`, `.test.yaml`, `.prod.yaml`) to parameterize SKUs and regions.
- Introduce Blueprint/CAF-aligned policy sets if your tenant already has established guardrails.
- Expand diagnostics to include Defender plans, DDoS protection, and change tracking.
- Wire in application landing zone modules (networking, identity, data) under `infra/**/modules` to complement the platform layer.

## Contributing

This starter kit is intentionally scaffolded. Open issues/PRs with improvements to policy baselines, pipelines, or reference modules to help others ramp quickly on Azure platform engineering.
