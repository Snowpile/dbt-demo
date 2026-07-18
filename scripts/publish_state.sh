#!/usr/bin/env bash
# Capture baseline manifests for all domains into state/<project>/.
# Run after a successful prod build (local or CI on main).
#
# Usage: ./scripts/publish_state.sh
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

for project in mart_finance mart_marketing mart_operations; do
	"$DBT_DEMO_ROOT/scripts/pull_state.sh" "$project"
done

echo "==> published state under ${DBT_STATE_ROOT:-$DBT_DEMO_ROOT/state}/"
