#!/usr/bin/env bash
set -euo pipefail

# Simple validation helper for contributors.
# - Lints Terraform formatting
# - Validates Terraform configuration (without backend)
# - Runs tfsec if installed

pushd "$(dirname "$0")/.." >/dev/null

if command -v terraform >/dev/null 2>&1; then
  terraform fmt -check -recursive infra/terraform
  (cd infra/terraform && terraform init -backend=false && terraform validate)
else
  echo "Terraform not found; skipping terraform lint/validate" >&2
fi

if command -v tfsec >/dev/null 2>&1; then
  tfsec infra/terraform
else
  echo "tfsec not found; skipping security scan" >&2
fi

popd >/dev/null
