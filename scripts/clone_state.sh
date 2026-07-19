#!/usr/bin/env bash
# Clone selected (or all) models from the state manifest into the defer sandbox schema.
# Useful when you want local relations that point at prod without rebuilding everything.
#
# Usage: ./scripts/clone_state.sh [project] [selector]
#   selector default: all models (empty → dbt clone default selection)
#
# Prerequisite: ./scripts/pull_state.sh <project>
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

DOMAIN="${1:-$DBT_PROJECT}"
SELECTOR="${2:-}"

case "$DOMAIN" in
mart_finance | finance) DOMAIN=mart_finance ;;
mart_marketing | marketing) DOMAIN=mart_marketing ;;
mart_operations | operations) DOMAIN=mart_operations ;;
*)
	echo "usage: $0 [mart_finance|mart_marketing|mart_operations] [selector]" >&2
	exit 1
	;;
esac

BASELINE_TARGET="${DBT_STATE_TARGET:-prod}"
DEV_SCHEMA="${DBT_DEV_SCHEMA:-dev}"
STATE_ROOT="${DBT_STATE_ROOT:-$DBT_DEMO_ROOT/state}"
STATE_DIR="$STATE_ROOT/$DOMAIN"

[[ -x "$DBT_DEMO_DBT" ]] || {
	echo "error: run ./setup.sh first" >&2
	exit 1
}
[[ -f "$STATE_DIR/manifest.json" ]] || {
	echo "error: missing $STATE_DIR/manifest.json — run ./scripts/pull_state.sh $DOMAIN first" >&2
	exit 1
}

echo "==> dbt clone: $DOMAIN state=$STATE_DIR target=$BASELINE_TARGET dev_schema=$DEV_SCHEMA"
(
	cd "$DBT_DEMO_ROOT/$DOMAIN"
	"$DBT_DEMO_DBT" deps
	args=(clone --state "$STATE_DIR" --vars "{\"dev_schema\":\"$DEV_SCHEMA\"}" --target "$BASELINE_TARGET")
	if [[ -n "$SELECTOR" ]]; then
		args+=(--select "$SELECTOR")
	fi
	"$DBT_DEMO_DBT" "${args[@]}"
)
