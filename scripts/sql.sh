#!/usr/bin/env bash
# Ad-hoc SQL against the demo DuckDB warehouse (qa/prod share prod.duckdb).
#
# Usage (repo root — run; do not source):
#   ./scripts/sql.sh "select * from raw.raw_orders limit 5"
#   ./scripts/sql.sh -t prod "select count(*) from raw.raw_orders"
#   ./scripts/sql.sh                                    # interactive REPL
#   echo "select 1;" | ./scripts/sql.sh
#
# Default is read-only. Pass --write for DDL/DML (avoid while dbt holds the file).

# Guard first — before set -e — so a mistaken `source` cannot kill the terminal.
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
	echo "error: do not source sql.sh (that can kill the terminal). Run:" >&2
	echo "  ./scripts/sql.sh \"select …\"" >&2
	return 1
fi

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

TARGET="$DBT_TARGET"
WRITE=()
SQL_ARGS=()

while [[ $# -gt 0 ]]; do
	case "$1" in
	-t | --target)
		TARGET="${2:?}"
		shift 2
		;;
	--write)
		WRITE=(--write)
		shift
		;;
	-h | --help)
		cat <<'EOF' >&2
Ad-hoc SQL against prod.duckdb (qa and prod targets use the same file).

Usage (repo root — run as ./scripts/sql.sh, do not source):
  ./scripts/sql.sh "select * from raw.raw_orders limit 5"
  ./scripts/sql.sh -t prod "select count(*) from raw.raw_orders"
  ./scripts/sql.sh                                    # interactive REPL
  echo "select 1;" | ./scripts/sql.sh

Default is read-only. Pass --write for DDL/DML (avoid while dbt holds the file).
EOF
		exit 0
		;;
	--)
		shift
		SQL_ARGS+=("$@")
		break
		;;
	*)
		SQL_ARGS+=("$1")
		shift
		;;
	esac
done

case "$TARGET" in
qa | prod) DB="$DUCKDB_PROD_PATH" ;;
*)
	echo "usage: sql.sh [-t qa|prod] [--write] [sql]" >&2
	exit 1
	;;
esac

if [[ ! -f "$DB" ]]; then
	echo "error: database not found: $DB (run ./scripts/load_raw.sh / a dbt build first)" >&2
	exit 1
fi

# Prefer an already-activated venv, then the repo .venv from env.sh.
if [[ -n "${VIRTUAL_ENV:-}" && -x "$VIRTUAL_ENV/bin/python" ]]; then
	PYTHON="$VIRTUAL_ENV/bin/python"
else
	PYTHON="$DBT_DEMO_PYTHON"
fi
if [[ ! -x "$PYTHON" ]]; then
	echo "error: python not found at $PYTHON — run: . ./setup.sh" >&2
	exit 1
fi

"$PYTHON" "$DBT_DEMO_ROOT/scripts/sql.py" "$DB" "${WRITE[@]}" "${SQL_ARGS[@]}"
