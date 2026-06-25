#!/usr/bin/env bash
# Usage: ./dbt_docs.sh [project] [port]
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/env.sh"

DOMAIN="${1:-$DBT_PROJECT}"
PORT="${2:-}"

case "$DOMAIN" in
  finance) PORT="${PORT:-$DBT_DOCS_PORT_FINANCE}" ;;
  marketing) PORT="${PORT:-$DBT_DOCS_PORT_MARKETING}" ;;
  operations) PORT="${PORT:-$DBT_DOCS_PORT_OPERATIONS}" ;;
  *)
	echo "usage: $0 [finance|marketing|operations] [port]" >&2
	exit 1
	;;
esac

[[ -x "$BENDERIK_DBT" ]] || {
	echo "error: run ./setup.sh first" >&2
	exit 1
}

"$BENDERIK_ROOT/scripts/load_raw.sh"

echo "==> dbt build: $DOMAIN"
(cd "$BENDERIK_ROOT/projects/$DOMAIN" && "$BENDERIK_DBT" build --target "$DBT_TARGET")

echo "==> dbt docs generate: $DOMAIN"
(cd "$BENDERIK_ROOT/projects/$DOMAIN" && "$BENDERIK_DBT" docs generate --target "$DBT_TARGET")

echo "==> dbt docs serve: $DOMAIN on http://127.0.0.1:${PORT}"
(cd "$BENDERIK_ROOT/projects/$DOMAIN" && "$BENDERIK_DBT" docs serve --target "$DBT_TARGET" --port "$PORT")
