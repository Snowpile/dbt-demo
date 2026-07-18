#!/usr/bin/env bash
# Slim-build every domain that has state/<project>/manifest.json.
# Selector default: state:modified+ (override with $1).
#
# Usage: ./scripts/slim_build_all.sh [selector]
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

SELECTOR="${1:-state:modified+}"
STATE_ROOT="${DBT_STATE_ROOT:-$DBT_DEMO_ROOT/state}"
ran=0

for project in mart_finance mart_marketing mart_operations; do
	if [[ ! -f "$STATE_ROOT/$project/manifest.json" ]]; then
		echo "==> skip $project (no $STATE_ROOT/$project/manifest.json)"
		continue
	fi
	"$DBT_DEMO_ROOT/scripts/slim_build.sh" "$project" "$SELECTOR"
	ran=$((ran + 1))
done

if [[ "$ran" -eq 0 ]]; then
	echo "error: no manifests under $STATE_ROOT — run ./scripts/publish_state.sh or download the CI artifact" >&2
	exit 1
fi

echo "==> slim_build_all done ($ran project(s), select=$SELECTOR)"
