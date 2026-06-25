#!/usr/bin/env bash
# Run dbt build for all domain projects (cron / local use).
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

"$BENDERIK_ROOT/scripts/load_raw.sh"

for domain in finance marketing operations; do
	echo "==> dbt build: $domain"
	(cd "$BENDERIK_ROOT/projects/$domain" && "$BENDERIK_DBT" build --target "$DBT_TARGET")
done

echo "All projects built."
