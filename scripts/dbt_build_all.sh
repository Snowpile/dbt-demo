#!/usr/bin/env bash
# Run dbt build for all domain projects (cron / local use).
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

"$DBT_DEMO_ROOT/scripts/load_raw.sh"

for project in mart_finance mart_marketing mart_operations; do
	echo "==> dbt build: $project"
	(cd "$DBT_DEMO_ROOT/$project" && "$DBT_DEMO_DBT" build --target "$DBT_TARGET")
done

echo "All projects built."
