#!/usr/bin/env bash
# Slim build: only state:modified+ (or another selector), deferring unselected refs to state/.
# Prerequisite: ./scripts/pull_state.sh <project> and prod DuckDB already built.
#
# Usage: ./scripts/slim_build.sh [project] [selector]
#   selector default: state:modified+
#
# Env:
#   DBT_STATE_ROOT    parent of state dirs (default: <repo>/state)
#   DBT_STATE_TARGET  must match the target used to capture state (default: prod)
#   DBT_DEV_SCHEMA    sandbox schema var for built nodes (default: dev)
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

DOMAIN="${1:-$DBT_PROJECT}"
SELECTOR="${2:-state:modified+}"

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

echo "==> slim build: $DOMAIN select=$SELECTOR defer-state=$STATE_DIR target=$BASELINE_TARGET"
(
	cd "$DBT_DEMO_ROOT/$DOMAIN"
	"$DBT_DEMO_DBT" build \
		--select "$SELECTOR" \
		--defer \
		--state "$STATE_DIR" \
		--vars "{\"dev_schema\":\"$DEV_SCHEMA\"}" \
		--target "$BASELINE_TARGET"
)
