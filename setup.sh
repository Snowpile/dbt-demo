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

# --- uv: find or install (POSIX: install.sh; Windows Git Bash: install.ps1 + uv.exe) ---
_dbt_demo_uv_bin_dirs() {
	local home_dir bin_dir homes=() seen=""
	homes+=("${HOME:-}")
	# Windows / Git Bash only — USERPROFILE is unset on normal Linux/macOS.
	if [[ -n "${USERPROFILE:-}" ]]; then
		homes+=("${USERPROFILE}")
		if command -v cygpath >/dev/null 2>&1; then
			homes+=("$(cygpath -u "$USERPROFILE" 2>/dev/null || true)")
		fi
		homes+=("$(echo "$USERPROFILE" | sed -e 's#\\#/#g' -e 's#^[Cc]:#/c#')")
	fi
	for home_dir in "${homes[@]}"; do
		[[ -z "$home_dir" ]] && continue
		for bin_dir in "${home_dir}/.local/bin" "${home_dir}/.cargo/bin"; do
			case " ${seen} " in
			*" ${bin_dir} "*) continue ;;
			esac
			seen="${seen} ${bin_dir}"
			echo "$bin_dir"
		done
	done
}

_dbt_demo_find_uv() {
	local p dir
	# Already on PATH (Homebrew, prior install, CI image, …).
	if command -v uv >/dev/null 2>&1; then
		command -v uv
		return 0
	fi
	# Standalone installer locations (Linux/macOS: ~/.local/bin/uv; Windows: …/uv.exe).
	while IFS= read -r dir; do
		[[ -z "$dir" ]] && continue
		for p in "${dir}/uv" "${dir}/uv.exe"; do
			if [[ -f "$p" && -x "$p" ]] || [[ -f "$p" ]]; then
				export PATH="${dir}:${PATH}"
				echo "$p"
				return 0
			fi
		done
	done < <(_dbt_demo_uv_bin_dirs)
	return 1
}

UV_BIN=""
if ! UV_BIN="$(_dbt_demo_find_uv)"; then
	echo "==> uv not found — installing (https://astral.sh/uv)"
	case "$(uname -s)" in
	CYGWIN* | MINGW* | MSYS*)
		powershell.exe -ExecutionPolicy ByPass -Command "irm https://astral.sh/uv/install.ps1 | iex"
		;;
	Darwin* | Linux* | *)
		# Official macOS / Linux (and any other Unix) installer.
		if command -v curl >/dev/null 2>&1; then
			curl -LsSf https://astral.sh/uv/install.sh | sh
		elif command -v wget >/dev/null 2>&1; then
			wget -qO- https://astral.sh/uv/install.sh | sh
		else
			echo "error: need curl or wget to install uv." >&2
			echo "Docs: https://docs.astral.sh/uv/getting-started/installation/" >&2
			false
		fi
		# New binary is usually here; ensure this sourced shell can see it.
		export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"
		;;
	esac
	hash -r 2>/dev/null || true
	if ! UV_BIN="$(_dbt_demo_find_uv)"; then
		echo "error: uv still not found after install." >&2
		case "$(uname -s)" in
		CYGWIN* | MINGW* | MSYS*)
			printf '  Expected: %%USERPROFILE%%\\.local\\bin\\uv.exe\n' >&2
			echo "  Fix: export PATH=\"\$HOME/.local/bin:\$PATH\" then: . ./setup.sh" >&2
			echo "  Or PowerShell: irm https://astral.sh/uv/install.ps1 | iex" >&2
			;;
		*)
			echo "  Expected: \$HOME/.local/bin/uv" >&2
			echo "  Fix: export PATH=\"\$HOME/.local/bin:\$PATH\" then: . ./setup.sh" >&2
			echo "  Or: curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
			;;
		esac
		false
	fi
fi
# Always call the resolved binary (no shell function — safe on Linux/macOS/Windows).
_uv_dir="$(dirname "$UV_BIN")"
export PATH="${_uv_dir}:${PATH}"
unset _uv_dir
echo "==> Using uv: $UV_BIN ($("$UV_BIN" --version 2>/dev/null | head -1))"

echo "==> Creating virtualenv (.venv) with uv (Python 3.11)"
"$UV_BIN" venv --python=python3.11

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
"$UV_BIN" pip install -e ".[dev]"

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
	# Drop legacy dev/staging keys from older env files.
	sed -i \
		-e '/^DUCKDB_DEV_PATH=/d' \
		-e '/^DUCKDB_STAGING_PATH=/d' \
		.env
	if grep -qE '^DBT_TARGET=(dev|staging)$' .env 2>/dev/null; then
		sed -i 's|^DBT_TARGET=.*|DBT_TARGET=qa|' .env
	fi
	if ! grep -q '^DBT_DOCS_PORT_COMBINED=' .env 2>/dev/null; then
		echo 'DBT_DOCS_PORT_COMBINED=8010' >>.env
	fi
fi

if [[ ! -f profiles.yml ]]; then
	echo "==> Creating profiles.yml from profiles.yml.example"
	cp profiles.yml.example profiles.yml
elif ! grep -qE '^\s+qa:' profiles.yml 2>/dev/null || grep -qE '^\s+target:\s*dev\s*$' profiles.yml 2>/dev/null; then
	echo "==> Refreshing profiles.yml from profiles.yml.example (qa + prod only)"
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
