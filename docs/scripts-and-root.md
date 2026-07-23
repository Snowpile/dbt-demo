# Scripts & repo-root files

Catalog of **`scripts/`** and **root-level** files for a later review pass.
Written for readers who are **not native bash** — each script has a short “what”
plus **hard spots** (idioms that look scary in the file).

Domain projects (`mart_*`), most of `docs/`, `.github/`, and `orchestration/` are out of
scope unless a root file points at them.

**Related:** `docs/defer.md` · `warehouse/ddl/` · `AGENTS.md`

---

## Typical flow

```
. ./setup.sh                  # venv + .env + profiles (no builds)
./scripts/bootstrap.sh        # scan seeds → load raw → dbt build all (prod)
./dbt_docs.sh mart_finance    # optional docs server
./scripts/sql.sh "select 1"   # optional ad-hoc SQL
```

Branch/PR work: `./scripts/pull_state.sh` → `./scripts/slim_build.sh` (`docs/defer.md`).

---

## Bash cheat sheet (patterns you will see)

These idioms repeat across the repo. Once you know them, the scripts get much easier.

| You see | Plain English |
|---------|----------------|
| `#!/usr/bin/env bash` | “Run this file with whatever `bash` is on PATH.” |
| `set -euo pipefail` | **Strict mode:** `-e` = exit if any command fails; `-u` = error on unset variables; `-o pipefail` = a failure mid-pipeline fails the whole pipeline. |
| `source file` or `. file` | Run `file` **inside the current shell** (exports stick). Opposite of `./file`, which runs in a **subshell** and then exits. |
| `"${VAR:-default}"` | Use `$VAR` if set/non-empty, else `default`. |
| `"${1:-$DBT_PROJECT}"` | First CLI arg, or fall back to `$DBT_PROJECT`. |
| `"${2:?}"` | Second arg **required** — script dies with an error if missing. |
| `[[ … ]]` | Bash test (safer than old `[ … ]`). |
| `[[ -f path ]]` / `[[ -d path ]]` / `[[ -x path ]]` | File exists / directory exists / file is executable. |
| `[[ -n "$x" ]]` / `[[ -z "$x" ]]` | String non-empty / empty. |
| `>&2` | Send that message to **stderr** (errors/help), not normal output. |
| `command -v foo` | “Is `foo` on PATH?” (portable `which`). |
| `>/dev/null 2>&1` | Hide stdout **and** stderr (often after a existence check). |
| `"${BASH_SOURCE[0]}"` | Path to **this** script file (even when sourced). More reliable than `$0` when sourced. |
| `"$0"` | How the shell was invoked (script name when executed). |
| `BASH_SOURCE[0] != $0` | Classic test: **was this file sourced?** (setup / sql guards). |
| `( cd dir && cmd )` | **Subshell:** `cd` only for this block; your terminal stays in the old directory. |
| `case "$x" in a\|b) … ;; esac` | Switch/match. `finance\|mart_finance)` accepts either alias. |
| `shift` / `shift 2` | Drop first arg / first two args from `$@` (used while parsing flags). |
| `WRITE=(--write)` then `"${WRITE[@]}"` | Bash **array** — expands to zero or one `--write` flag cleanly. |
| `cat <<'EOF' … EOF` | Print a multi-line help block. Quotes around `EOF` mean **no** variable expansion inside. |
| `"$PY" <<'PY' … PY` | Feed a whole Python program into the interpreter via stdin (heredoc). |
| `sed -i -e 's|…|…|' file` | Edit file **in place**. (setup refreshes `.env` paths.) |
| `DBT_TARGET=prod ./scripts/…` | Set an env var **only for that one command**. |

**Source vs run (important):**

| Command | Effect |
|---------|--------|
| `. ./setup.sh` | Env/venv activation stays in **your** terminal. Correct for setup. |
| `./scripts/sql.sh "…"` | Runs and exits. Correct for sql/bootstrap/slim. |
| `. ./scripts/sql.sh` | **Wrong** — with `set -e`, a failed SQL can kill your whole terminal. `sql.sh` refuses this. |

---

## `scripts/` — one by one

Almost every script starts by sourcing `env.sh` so paths and defaults are consistent.

### Dependency sketch

```
setup.sh (root)
    └── env.sh

bootstrap.sh
    ├── scan_downloads.sh
    └── dbt_build_all.sh
            ├── load_raw.sh → scan_downloads.sh + load_raw.py
            └── dbt build × 3 domains

slim_build.sh ← pull_state.sh (manifest)
publish_state.sh → pull_state.sh × 3
slim_build_all.sh → slim_build.sh × available
clone_state.sh ← pull_state.sh
sql.sh → sql.py
dbt_docs.sh (root) → env.sh
```

---

### `env.sh` — shared environment loader

**What:** Sets repo root, loads `.env` as *defaults*, exports DuckDB path, dbt target/project, docs ports, and paths to venv `dbt` / `python`.

**Source only** — other scripts `source` it; you rarely run it alone.

**Hard spots:**

- **Idempotent guard:** `[[ -n "${DBT_DEMO_ENV_LOADED:-}" ]] && return 0` — if already loaded in this shell, bail out immediately so sourcing twice is safe.
- **Find repo root:**
  `DBT_DEMO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"`
  = “directory of this script → go up one (`..`) → absolute path.” Works no matter where you invoked the caller from.
- **`.env` loop with trim:** The `ltrim`/`rtrim` lines look like line noise; they strip leading/trailing spaces from keys. Skip blank lines and `#` comments.
- **`${!_key:-}` (indirect expansion):** “Value of the variable *named* by `$_key`.” Used so: *only export from `.env` if that variable is not already set in the environment* (CLI wins over file).
- **Windows vs POSIX venv:** looks for `.venv/Scripts` (Windows) else `.venv/bin` (Linux/macOS).

---

### `bootstrap.sh` — full warehouse warm-up

**What:** Seed integrity scan, then build all domains on **prod** (same as CI / local pre-warm). Demo Part A only runs `. ./setup.sh` on screen — not this.

**Hard spots:**

- `DBT_TARGET=prod "$DBT_DEMO_ROOT/scripts/dbt_build_all.sh"` — forces prod for that child only; does not permanently change your shell’s `DBT_TARGET`.

---

### `scan_downloads.sh` — seed integrity

**What:** Trust checks on `data/seeds/*.csv` before load: checksums, “looks like text/CSV”, no null bytes, parseable UTF-8 headers/row counts. No antivirus required.

**Hard spots:**

- Uses `dirname "$0"` (same idea as `BASH_SOURCE`, fine when **executed**).
- Picks `python3` or `python` depending on OS.
- Checksums: Linux `sha256sum -c`; macOS often only has `shasum -a 256 -c`.
- Embedded Python via `"$PY" -c "…"` and a larger `"$PY" <<'PY' … PY` block for DictReader column checks.

---

### `load_raw.sh` + `load_raw.py` — CSV → DuckDB `raw.*`

**What (shell):** Run scan, map `qa`/`prod` → same `DUCKDB_PROD_PATH`, call Python.

**What (Python):** `CREATE SCHEMA raw` + `CREATE OR REPLACE TABLE` from each CSV via `read_csv_auto`.

**Hard spots (shell):**

- `TARGET="${1:-$DBT_TARGET}"` — optional first arg, else default from env.
- `case` rejects anything other than `qa`/`prod`.

---

### `dbt_build_all.sh` — all three domains

**What:** `load_raw.sh`, then for each mart: `cd` into project → `dbt deps` → `dbt build --target $DBT_TARGET`.

**Hard spots:**

- The `( cd … && … )` subshell keeps your cwd unchanged after each domain.
- Sequential on purpose — DuckDB is **single-writer** per file.

---

### `sql.sh` + `sql.py` — ad-hoc SQL

**What:** Query (or optionally write) `data/prod.duckdb`. One-shot SQL, piped SQL, or REPL.

**Hard spots (`sql.sh` — read carefully):**

1. **Source guard before `set -e`:**
   If you `source` this file, a later failure would inherit `set -e` and can **close your terminal**. So it checks `BASH_SOURCE[0] != $0`, prints an error, and `return 1` (return works when sourced; `exit` would be wrong there).
2. **Manual flag parsing loop** (`while [[ $# -gt 0 ]]; do case …`): walks args, handles `-t`/`--target`, `--write`, `--help`, and collects leftover SQL into `SQL_ARGS`.
3. **`WRITE=(--write)` array:** empty by default; with `--write` becomes one element so `"${WRITE[@]}"` expands cleanly into the Python argv.
4. Prefer already-activated `VIRTUAL_ENV` python, else repo `.venv` from `env.sh`.

**`sql.py`:** opens DuckDB read-only unless `--write`; REPL buffers lines until a statement ending in `;`.

---

### `pull_state.sh` — capture defer baseline

**What:** Writes `state/<project>/manifest.json` by compiling with `--target-path` pointed at that folder (not the usual `target/`). Needed before local slim/defer.

**Hard spots:**

- Alias `case`: `finance` → `mart_finance`, etc.
- `[[ -x "$DBT_DEMO_DBT" ]] || { …; exit 1; }` — “executable exists or fail with message.”
- Subshell `cd` into the mart, then `dbt compile --target-path "$STATE_DIR"`.

---

### `publish_state.sh` — all-domain manifests

**What:** Loop: `pull_state.sh` for finance, marketing, operations. Run after a successful prod build (local or CI).

**Hard spots:** Straightforward loop; no exotic bash.

---

### `slim_build.sh` — Slim CI locally

**What:** Build only `state:modified+` (or another selector), `--defer` to the saved manifest, write into `dev_schema` sandbox on the prod target/file.

**Hard spots:**

- `"${2:-state:modified+}"` — default selector if you omit arg 2.
- JSON in `--vars`: `"{\"dev_schema\":\"$DEV_SCHEMA\"}"` — escaped quotes so bash passes real JSON to dbt.
- Same `( cd mart && dbt … )` subshell pattern.

Detail: `docs/defer.md`.

---

### `slim_build_all.sh` — slim every project that has state

**What:** For each domain, skip if no `manifest.json`, else call `slim_build.sh`. Error if none ran.

**Hard spots:**

- `ran=$((ran + 1))` — arithmetic increment.
- Skip message when state missing (so partial local state still works).

---

### `clone_state.sh` — `dbt clone` into sandbox

**What:** Create local relations in the defer schema that point at prod objects (without rebuilding everything). Optional selector.

**Hard spots:**

- Builds an `args=(clone …)` array, then optionally appends `--select`, then `"$DBT_DEMO_DBT" "${args[@]}"` — clean way to pass a variable-length command.

---

## Root-level entry scripts

### `setup.sh` — laptop environment (source this)

**What:** Create `.venv`, install `.[dev]`, optional pre-commit hooks, create/refresh `.env` + `profiles.yml`, source `env.sh`, print `dbt --version`. **No warehouse builds.**

**Hard spots (this is the trickiest root script):**

1. **Must be sourced:** `. ./setup.sh` so `activate` and exports stay in your shell.
2. **Option restore when sourced:** It turns on `set -euo pipefail`. If that leaked into your interactive terminal, the *next* failing command could kill the session. So when sourced it:
   - Saves current options: `_DBT_DEMO_SETUP_OPTS="$(set +o)"`
   - Registers `trap '…restore…' RETURN ERR` to put options back when the script finishes or errors
3. **`false` after “uv missing”:** with `set -e`, `false` forces a failure exit (after printing install help).
4. **`uname -s` case:** activate `.venv/bin` (Unix) vs `.venv/Scripts` (Git Bash/Windows).
5. **`sed` on `.env`:** first run copies example and substitutes your absolute repo path; later runs rewrite `DBT_PROFILES_DIR` / `DUCKDB_PROD_PATH` if you moved the repo.

---

### `dbt_docs.sh` — docs site

**What:** For a domain mart: load raw → build → `docs generate` → `docs serve`. For `mart_combined`: deps + prepare script + generate (no build) → serve.

**Hard spots:**

- Same alias `case` as other scripts (`finance` → `mart_finance`, `all` → `mart_combined`).
- `PORT="${PORT:-$DBT_DOCS_PORT_…}"` — use CLI port if given, else env default.
- `COMBINED=1` flag branches the “no build” docs-only path.
- Blocks until you Ctrl+C the server (foreground `docs serve`).

---

### `setup.py` + `requirements.json`

**What:** Packaging metadata. `setup.py` reads JSON for install/extras. `setup.sh` runs `uv pip install -e ".[dev]"`. Prefect/Airflow extras exist for stubs but are **not** installed by default.

---

## Other root files & folders

### Env / profiles

| Path | What it is |
|------|------------|
| **`.env.example`** | Template paths/defaults. Committed. |
| **`.env`** | Your machine’s absolute paths. **Gitignored.** |
| **`profiles.yml.example`** | dbt profile `dbt_demo`: `qa` + `prod` → same DuckDB file. |
| **`profiles.yml`** | Local profile copy. **Gitignored.** |

### Docs & agents

| Path | What it is |
|------|------------|
| **`README.md`** | Human overview, quick start, CI, planned backlog. |
| **`AGENTS.md`** | AI/agent operating rules for this repo. |
| **`CLAUDE.md`** | `@AGENTS.md` pointer for Claude Code. |
| **`docs/`** | Handoff, demo agenda, feature guide, defer, conventions, **this file**. |

### Tooling

| Path | What it is |
|------|------------|
| **`.pre-commit-config.yaml`** | Hygiene + Ruff + SQLFluff + dbt-checkpoint hooks. |
| **`ruff.toml`** | Python lint/format (`scripts/`, `setup.py`). |
| **`.sqlfluff`** | SQL lint for dbt models (DuckDB + Jinja stubs). |
| **`.gitignore`** | Keeps secrets, DuckDB, `target/`, `state/`, `.venv/` out of git; keeps seeds + examples. |
| **`.cursorignore`** | Shrinks Cursor context (not security). |

### Data & warehouse (non-dbt)

| Path | What it is |
|------|------------|
| **`data/seeds/`** | Vendored CSVs + checksums / provenance. Committed. |
| **`data/prod.duckdb`** | Local warehouse (qa+prod). **Gitignored.** |
| **`warehouse/ddl/architectural_ddl.sql`** | One-off DDL: `audit` schema + `dbt_model_hooks` table (finance hooks). Not part of the dbt DAG. |

### Domains / CI / orchestration (pointers)

| Path | What it is |
|------|------------|
| **`mart_*`** | Real dbt projects; `mart_combined` = docs-only DAG. |
| **`.github/workflows/`** | `ci.yml`, `pre-commit.yml`, `orchestrate.yml` stub. |
| **`orchestration/`** | Prefect/Airflow stubs. |
| **`state/`** | Local defer manifests. **Gitignored.** |

### Usually skip while reviewing

`.venv/`, `dbt_demo.egg-info/`, `.ruff_cache/`, `.vscode/`, `.user.yml`, `*.duckdb.wal`.

---

## `warehouse/ddl` vs `scripts/`

| Concern | Where |
|---------|--------|
| Bootstrap, load, slim, ad-hoc SQL | `scripts/` |
| One-shot schemas / audit / grants (not in DAG) | `warehouse/ddl/` |

```bash
duckdb "$DUCKDB_PROD_PATH" < warehouse/ddl/architectural_ddl.sql
# or: ./scripts/sql.sh --write "$(cat warehouse/ddl/architectural_ddl.sql)"
```

---

## Quick “what should I open?”

| Goal | Open |
|------|------|
| First-time laptop setup | `setup.sh` (+ bash cheat sheet above) |
| Full rebuild like CI | `bootstrap.sh` → `dbt_build_all.sh` |
| Seed trust | `scan_downloads.sh`, `data/seeds/` |
| Query warehouse | `sql.sh` / `sql.py` |
| Defer / slim locally | `pull_state.sh`, `slim_build.sh`, `docs/defer.md` |
| Audit DDL | `warehouse/ddl/architectural_ddl.sql` |
| Agent rules | `AGENTS.md` |
| Lint policy | `.pre-commit-config.yaml`, `ruff.toml`, `.sqlfluff` |
