#!/usr/bin/env bash
# Warehouse bootstrap: validate seeds, load raw, dbt build all domains (dev + prod).
# Run after setup.sh — CI and local pre-warm. Demo Part A only runs `. ./setup.sh` live.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

echo "==> Seed integrity check"
"$DBT_DEMO_ROOT/scripts/scan_downloads.sh"

echo "==> Building all domains (dev)"
"$DBT_DEMO_ROOT/scripts/dbt_build_all.sh"

echo "==> Building all domains (prod)"
DBT_TARGET=prod "$DBT_DEMO_ROOT/scripts/dbt_build_all.sh"

echo ""
echo "Bootstrap complete (dev + prod)."
