#!/usr/bin/env bash
# Load vendored CSV seeds into DuckDB schema `raw`.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-$ROOT}"
export DUCKDB_DEV_PATH="${DUCKDB_DEV_PATH:-$ROOT/data/dev.duckdb}"
export DUCKDB_STAGING_PATH="${DUCKDB_STAGING_PATH:-$ROOT/data/staging.duckdb}"
export DUCKDB_PROD_PATH="${DUCKDB_PROD_PATH:-$ROOT/data/prod.duckdb}"
TARGET="${1:-dev}"

"$ROOT/scripts/scan_downloads.sh"

case "$TARGET" in
  dev)     DB="${DUCKDB_DEV_PATH:-$ROOT/data/dev.duckdb}" ;;
  staging) DB="${DUCKDB_STAGING_PATH:-$ROOT/data/staging.duckdb}" ;;
  prod)    DB="${DUCKDB_PROD_PATH:-$ROOT/data/prod.duckdb}" ;;
  *) echo "usage: load_raw.sh [dev|staging|prod]"; exit 1 ;;
esac

mkdir -p "$(dirname "$DB")"
cd "$ROOT"
uv run python scripts/load_raw.py --database "$DB"
echo "Loaded raw.* into $DB"
