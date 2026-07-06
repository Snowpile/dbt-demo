#!/usr/bin/env bash
# Load vendored CSV seeds into DuckDB schema `raw`.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

TARGET="${1:-$DBT_TARGET}"

"$DBT_DEMO_ROOT/scripts/scan_downloads.sh"

case "$TARGET" in
dev) DB="$DUCKDB_DEV_PATH" ;;
staging) DB="$DUCKDB_STAGING_PATH" ;;
prod) DB="$DUCKDB_PROD_PATH" ;;
*)
	echo "usage: load_raw.sh [dev|staging|prod]" >&2
	exit 1
	;;
esac

mkdir -p "$(dirname "$DB")"
"$DBT_DEMO_PYTHON" "$DBT_DEMO_ROOT/scripts/load_raw.py" --database "$DB"
echo "Loaded raw.* into $DB"
