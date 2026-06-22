#!/usr/bin/env bash
# Run dbt build for all domain projects (cron / local use).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-$ROOT}"
export DUCKDB_DEV_PATH="${DUCKDB_DEV_PATH:-$ROOT/data/dev.duckdb}"
export DUCKDB_STAGING_PATH="${DUCKDB_STAGING_PATH:-$ROOT/data/staging.duckdb}"
export DUCKDB_PROD_PATH="${DUCKDB_PROD_PATH:-$ROOT/data/prod.duckdb}"
TARGET="${DBT_TARGET:-dev}"

"$ROOT/scripts/load_raw.sh" "$TARGET"

for domain in finance marketing operations; do
  echo "==> dbt build: $domain"
  (cd "$ROOT/projects/$domain" && uv run dbt build --target "$TARGET")
done

echo "All projects built."
