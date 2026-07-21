#!/usr/bin/env bash
# After `dbt deps` in mart_combined: replace marketing/operations symlinks with
# copies and strip shared {% docs %} that collide with mart_finance.
# Does not modify the source mart_* projects.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$(cd "$ROOT/.." && pwd)/scripts/env.sh"

PACKAGES="$ROOT/dbt_packages"
REPO="$DBT_DEMO_ROOT"

if [[ ! -d "$PACKAGES" ]]; then
	echo "error: dbt_packages/ missing — run dbt deps first" >&2
	exit 1
fi

for pkg in mart_marketing mart_operations; do
	src="$REPO/$pkg"
	dst="$PACKAGES/$pkg"
	if [[ ! -d "$src" ]]; then
		echo "error: missing source project $src" >&2
		exit 1
	fi
	rm -rf "$dst"
	mkdir -p "$dst"
	# Copy project contents; skip build artifacts and nested deps.
	rsync -a \
		--exclude dbt_packages \
		--exclude target \
		--exclude .git \
		"$src/" "$dst/"
	echo "vendored copy: $pkg"
done

"$DBT_DEMO_PYTHON" "$ROOT/strip_duplicate_docs.py"
