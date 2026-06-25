#!/usr/bin/env bash
# Shared env for benderik scripts. Source, don't execute.
[[ -n "${BENDERIK_ENV_LOADED:-}" ]] && return 0
BENDERIK_ENV_LOADED=1

BENDERIK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load .env as defaults only — values already in the environment (e.g. set on
# the command line) take precedence over .env.
if [[ -f "$BENDERIK_ROOT/.env" ]]; then
	while IFS='=' read -r _key _val; do
		_key="${_key#"${_key%%[![:space:]]*}"}"   # ltrim
		_key="${_key%"${_key##*[![:space:]]}"}"     # rtrim
		[[ -z "$_key" || "$_key" == \#* ]] && continue
		[[ -z "${!_key:-}" ]] && export "$_key=$_val"
	done < "$BENDERIK_ROOT/.env"
	unset _key _val
fi

export DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-$BENDERIK_ROOT}"
export DUCKDB_DEV_PATH="${DUCKDB_DEV_PATH:-$BENDERIK_ROOT/data/dev.duckdb}"
export DUCKDB_STAGING_PATH="${DUCKDB_STAGING_PATH:-$BENDERIK_ROOT/data/staging.duckdb}"
export DUCKDB_PROD_PATH="${DUCKDB_PROD_PATH:-$BENDERIK_ROOT/data/prod.duckdb}"

export DBT_TARGET="${DBT_TARGET:-dev}"
export DBT_PROJECT="${DBT_PROJECT:-finance}"
export DBT_DOCS_PORT_FINANCE="${DBT_DOCS_PORT_FINANCE:-8011}"
export DBT_DOCS_PORT_MARKETING="${DBT_DOCS_PORT_MARKETING:-8012}"
export DBT_DOCS_PORT_OPERATIONS="${DBT_DOCS_PORT_OPERATIONS:-8013}"

export BENDERIK_DBT="${BENDERIK_ROOT}/.venv/bin/dbt"
export BENDERIK_PYTHON="${BENDERIK_ROOT}/.venv/bin/python"
