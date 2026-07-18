#!/usr/bin/env bash
# Capture a baseline dbt manifest into state/<project>/ for --defer / state: selectors.
# Prerequisite: that project's models already built on --target prod (same DuckDB file).
#
# Usage: ./scripts/pull_state.sh [mart_finance|mart_marketing|mart_operations]
#
# Env:
#   DBT_STATE_ROOT    override parent of per-project state dirs (default: <repo>/state)
#   DBT_STATE_TARGET  warehouse target for the baseline manifest (default: prod)
#                     (not DBT_TARGET — that is often left as "dev" in .env)
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

DOMAIN="${1:-$DBT_PROJECT}"
case "$DOMAIN" in
mart_finance | finance) DOMAIN=mart_finance ;;
mart_marketing | marketing) DOMAIN=mart_marketing ;;
mart_operations | operations) DOMAIN=mart_operations ;;
*)
	echo "usage: $0 [mart_finance|mart_marketing|mart_operations]" >&2
	exit 1
	;;
esac

BASELINE_TARGET="${DBT_STATE_TARGET:-prod}"
STATE_ROOT="${DBT_STATE_ROOT:-$DBT_DEMO_ROOT/state}"
STATE_DIR="$STATE_ROOT/$DOMAIN"

[[ -x "$DBT_DEMO_DBT" ]] || {
	echo "error: run ./setup.sh first" >&2
	exit 1
}

mkdir -p "$STATE_DIR"

echo "==> capture state: $DOMAIN (target=$BASELINE_TARGET) → $STATE_DIR"
(
	cd "$DBT_DEMO_ROOT/$DOMAIN"
	# --target-path writes manifest.json into STATE_DIR (not the project's target/).
	"$DBT_DEMO_DBT" compile --target "$BASELINE_TARGET" --target-path "$STATE_DIR"
)

[[ -f "$STATE_DIR/manifest.json" ]] || {
	echo "error: expected $STATE_DIR/manifest.json after compile" >&2
	exit 1
}

echo "==> ok: $STATE_DIR/manifest.json"
echo "    slim build: ./scripts/slim_build.sh $DOMAIN"
echo "    or:  cd $DOMAIN && dbt build --select state:modified+ --defer --state $STATE_DIR \\"
echo "           --vars '{\"dev_schema\":\"dev\"}' --target $BASELINE_TARGET"
