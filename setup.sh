#!/usr/bin/env bash
# Create .venv and install dependencies for benderik.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

PYTHON_VERSION="${PYTHON_VERSION:-3.10}"
PYTHON="${PYTHON:-python${PYTHON_VERSION}}"

if ! command -v "$PYTHON" >/dev/null 2>&1; then
	PYTHON=python3
fi

if ! command -v "$PYTHON" >/dev/null 2>&1; then
	echo "error: Python ${PYTHON_VERSION}+ is required." >&2
	exit 1
fi

echo "==> Creating virtualenv (.venv) with ${PYTHON}"
if [[ ! -d .venv ]]; then
	"$PYTHON" -m venv .venv
fi

echo "==> Installing dependencies from requirements.json"
.venv/bin/pip install --upgrade pip
.venv/bin/pip install -e ".[dev]"

if [[ ! -f .env ]]; then
	echo "==> Creating .env from .env.example"
	sed "s|/absolute/path/to/benderik|${ROOT}|g" .env.example > .env
fi

if [[ ! -f profiles.yml ]]; then
	echo "==> Creating profiles.yml from profiles.yml.example"
	cp profiles.yml.example profiles.yml
fi

mkdir -p data

echo ""
echo "Setup complete."
echo ""
echo "Activate (optional):"
if [[ -f .venv/bin/activate ]]; then
	echo "  source .venv/bin/activate"
elif [[ -f .venv/Scripts/activate ]]; then
	echo "  source .venv/Scripts/activate"
fi
echo ""
echo "Verify:"
echo "  .venv/bin/dbt --version"
echo "  ./scripts/dbt_build_all.sh"
echo "  ./dbt_docs.sh"
