#!/usr/bin/env bash
# Warehouse bootstrap: validate seeds, load raw, dbt build all domains (prod baseline).
# Run after setup.sh — CI and local pre-warm. Demo Part A only runs `. ./setup.sh` live.
# Branch/PR work uses --defer + dev_schema on this prod warehouse (see docs/defer.md).
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

echo "==> Seed integrity check"
"$DBT_DEMO_ROOT/scripts/scan_downloads.sh"

echo "==> Building all domains (prod baseline)"
DBT_TARGET=prod "$DBT_DEMO_ROOT/scripts/dbt_build_all.sh"

echo ""
echo "Bootstrap complete (prod)."
