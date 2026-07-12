#!/usr/bin/env bash
# Python environment + local config for dbt_demo (fast — no dbt builds).
# Source for an interactive shell: `. ./setup.sh`
# Warehouse builds: `./scripts/bootstrap.sh` (pre-warm or live in demo Part A).
set -euo pipefail

# Set the root directory of the project and enter
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

# If uv is not installed, print an error message, how to install, and exit
if ! command -v uv >/dev/null 2>&1; then
	echo "error: uv is required." >&2
	echo "Install: https://docs.astral.sh/uv/getting-started/installation/" >&2
	exit 1
fi

echo "==> Creating virtualenv (.venv) with uv (Python 3.11)"
uv venv --python=python3.11

case "$(uname -s)" in
Darwin* | Linux*)
	source .venv/bin/activate
	;;
CYGWIN* | MINGW32* | MSYS* | MINGW*)
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
		-e "s|^DUCKDB_DEV_PATH=.*|DUCKDB_DEV_PATH=${ROOT}/data/dev.duckdb|" \
		-e "s|^DUCKDB_STAGING_PATH=.*|DUCKDB_STAGING_PATH=${ROOT}/data/staging.duckdb|" \
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
source "$ROOT/scripts/env.sh"

echo "==> Verifying dbt"
"$DBT_DEMO_DBT" --version

echo ""
echo "Environment ready."
echo "Next: ./scripts/bootstrap.sh   # seed scan + load raw + dbt build (dev + prod)"
echo "Docs (second terminal, after bootstrap): ./dbt_docs.sh finance"
