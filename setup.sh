#!/usr/bin/env bash
# Bootstrap dbt_demo: venv, config, seed scan, dev + prod builds.
# Interactive use: ends in projects/finance with scripts/env.sh loaded (via exec).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if ! command -v uv >/dev/null 2>&1; then
	echo "error: uv is required." >&2
	echo "Install: https://docs.astral.sh/uv/getting-started/installation/" >&2
	exit 1
fi

echo "==> Creating virtualenv (.venv) with uv (Python 3.11)"
uv venv --python=python3.11

case "$(uname -s)" in
Darwin* | Linux*)
	source ./.venv/bin/activate
	;;
CYGWIN* | MINGW32* | MSYS* | MINGW*)
	source ./.venv/Scripts/activate
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
fi

if [[ ! -f profiles.yml ]]; then
	echo "==> Creating profiles.yml from profiles.yml.example"
	cp profiles.yml.example profiles.yml
fi

mkdir -p data

echo "==> Loading environment"
# shellcheck source=scripts/env.sh
source "$ROOT/scripts/env.sh"

echo "==> Verifying dbt"
"$DBT_DEMO_DBT" --version

echo "==> Seed integrity check"
"$ROOT/scripts/scan_downloads.sh"

echo "==> Building all domains (dev)"
"$ROOT/scripts/dbt_build_all.sh"

echo "==> Building all domains (prod)"
DBT_TARGET=prod "$ROOT/scripts/dbt_build_all.sh"

echo ""
echo "Setup complete."

if [[ -z "${CI:-}" && -t 0 && -t 1 ]]; then
	echo "==> Entering project shell (projects/${DBT_PROJECT})"
	cd "$ROOT/projects/$DBT_PROJECT"
	exec "${SHELL:-bash}" -i
fi

echo ""
echo "Docs (second terminal): ./dbt_docs.sh finance"
