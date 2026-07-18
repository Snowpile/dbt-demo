#!/usr/bin/env bash
# Shared env for dbt_demo scripts. Source, don't execute.
[[ -n "${DBT_DEMO_ENV_LOADED:-}" ]] && return 0
DBT_DEMO_ENV_LOADED=1

DBT_DEMO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load .env as defaults only — values already in the environment (e.g. set on
# the command line) take precedence over .env.
if [[ -f "$DBT_DEMO_ROOT/.env" ]]; then
	while IFS='=' read -r _key _val; do
		_key="${_key#"${_key%%[![:space:]]*}"}" # ltrim
		_key="${_key%"${_key##*[![:space:]]}"}" # rtrim
		[[ -z "$_key" || "$_key" == \#* ]] && continue
		[[ -z "${!_key:-}" ]] && export "$_key=$_val"
	done <"$DBT_DEMO_ROOT/.env"
	unset _key _val
fi

export DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-$DBT_DEMO_ROOT}"
export DUCKDB_DEV_PATH="${DUCKDB_DEV_PATH:-$DBT_DEMO_ROOT/data/dev.duckdb}"
export DUCKDB_STAGING_PATH="${DUCKDB_STAGING_PATH:-$DBT_DEMO_ROOT/data/staging.duckdb}"
export DUCKDB_PROD_PATH="${DUCKDB_PROD_PATH:-$DBT_DEMO_ROOT/data/prod.duckdb}"

export DBT_TARGET="${DBT_TARGET:-dev}"
export DBT_PROJECT="${DBT_PROJECT:-mart_finance}"
export DBT_DOCS_PORT_FINANCE="${DBT_DOCS_PORT_FINANCE:-8011}"
export DBT_DOCS_PORT_MARKETING="${DBT_DOCS_PORT_MARKETING:-8012}"
export DBT_DOCS_PORT_OPERATIONS="${DBT_DOCS_PORT_OPERATIONS:-8013}"
export DBT_DOCS_PORT_COMBINED="${DBT_DOCS_PORT_COMBINED:-8010}"

# uv/venv layout differs by OS: POSIX uses .venv/bin, Windows uses .venv/Scripts.
if [[ -d "$DBT_DEMO_ROOT/.venv/Scripts" ]]; then
	DBT_DEMO_VENV_BIN="$DBT_DEMO_ROOT/.venv/Scripts"
else
	DBT_DEMO_VENV_BIN="$DBT_DEMO_ROOT/.venv/bin"
fi
export DBT_DEMO_VENV_BIN
# Bare names; on Windows (Git Bash/MSYS) the exec layer resolves the .exe.
export DBT_DEMO_DBT="${DBT_DEMO_VENV_BIN}/dbt"
export DBT_DEMO_PYTHON="${DBT_DEMO_VENV_BIN}/python"
