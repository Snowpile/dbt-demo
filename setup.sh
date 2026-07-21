#!/usr/bin/env bash
# Python environment + local config for dbt_demo (fast — no dbt builds).
# Source for an interactive shell: `. ./setup.sh`
# Warehouse builds: `./scripts/bootstrap.sh` (CI / local pre-warm — not on-screen in the demo).
#
# When sourced, restore the caller's shell options on finish — otherwise `set -e`
# stays on and the next failing command kills the Cursor/VS Code terminal.

_DBT_DEMO_SETUP_SOURCED=0
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	_DBT_DEMO_SETUP_SOURCED=1
	_DBT_DEMO_SETUP_OPTS="$(set +o)"
	_dbt_demo_restore_opts() {
		trap - RETURN ERR
		eval "${_DBT_DEMO_SETUP_OPTS:-}" 2>/dev/null || true
		unset _DBT_DEMO_SETUP_OPTS _DBT_DEMO_SETUP_SOURCED
	}
	trap '_dbt_demo_restore_opts' RETURN ERR
fi

set -euo pipefail

# Set the root directory of the project and enter
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

# If uv is not installed, print an error message, how to install, and stop
if ! command -v uv >/dev/null 2>&1; then
	echo "error: uv is required." >&2
	echo "Install: https://docs.astral.sh/uv/getting-started/installation/" >&2
	false
fi

echo "==> Creating virtualenv (.venv) with uv (Python 3.11)"
uv venv --python=python3.11

case "$(uname -s)" in
Darwin* | Linux*)
	# shellcheck disable=SC1091
	source .venv/bin/activate
	;;
CYGWIN* | MINGW32* | MSYS* | MINGW*)
	# shellcheck disable=SC1091
	source .venv/Scripts/activate
	;;
*)
	echo "Other OS detected — activate .venv manually."
	;;
esac

echo "==> Installing dependencies (uv pip install -e .[dev])"
uv pip install -e ".[dev]"

if [[ -d .git ]]; then
	echo "==> Installing git pre-commit hooks"
	pre-commit install
fi

if [[ ! -f .env ]]; then
	echo "==> Creating .env from .env.example"
	sed "s|/absolute/path/to/dbt_demo|${ROOT}|g" .env.example >.env
else
	echo "==> Refreshing .env paths for this machine (${ROOT})"
	# Repo may have moved or been renamed since first setup; path keys must match ROOT.
	sed -i \
		-e "s|^DBT_PROFILES_DIR=.*|DBT_PROFILES_DIR=${ROOT}|" \
		-e "s|^DUCKDB_PROD_PATH=.*|DUCKDB_PROD_PATH=${ROOT}/data/prod.duckdb|" \
		.env
fi

if [[ ! -f profiles.yml ]]; then
	echo "==> Creating profiles.yml from profiles.yml.example"
	cp profiles.yml.example profiles.yml
fi

# Ensure the data directory exists before creating files there.
mkdir -p data

echo "==> Loading environment"
# shellcheck disable=SC1091
source "$ROOT/scripts/env.sh"

echo "==> Verifying dbt"
"$DBT_DEMO_DBT" --version

echo ""
echo "Environment ready."
echo "Next: ./scripts/bootstrap.sh   # seed scan + load raw + prod dbt build (baseline)"
echo "Docs (second terminal, after bootstrap): ./dbt_docs.sh mart_finance"
