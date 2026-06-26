#!/usr/bin/env bash
# Create .venv (uv) and install benderik deps from requirements.json (setup.py).
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
	sed "s|/absolute/path/to/benderik|${ROOT}|g" .env.example >.env
fi

if [[ ! -f profiles.yml ]]; then
	echo "==> Creating profiles.yml from profiles.yml.example"
	cp profiles.yml.example profiles.yml
fi

mkdir -p data

echo ""
echo "Setup complete."
echo ""
echo "Verify:"
echo "  uv run dbt --version"
echo "  ./scripts/dbt_build_all.sh"
echo "  ./dbt_docs.sh"
