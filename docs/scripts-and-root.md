# Scripts & repo-root files

Catalog of **`scripts/`** and **root-level** files you will walk when reviewing the repo.
Domain projects (`mart_*`), `docs/` (except this file), `.github/`, and `orchestration/` are out of scope here unless a root file points at them.

**Related:** `docs/defer.md` (slim/state) · `warehouse/ddl/` (one-off DDL) · `AGENTS.md` (agent rules).

---

## Typical flow

```
. ./setup.sh                  # venv + .env + profiles (no builds)
./scripts/bootstrap.sh        # scan seeds → load raw → dbt build all (prod)
./dbt_docs.sh mart_finance    # optional docs server
./scripts/sql.sh "select 1"   # optional ad-hoc SQL
```

Branch/PR work: `./scripts/pull_state.sh` → `./scripts/slim_build.sh` (see `docs/defer.md`).

---

## `scripts/`

Shared bash/Python helpers. Almost all `source` `scripts/env.sh` first. Run from **repo root** unless noted.

| File | What it does |
|------|----------------|
| **`env.sh`** | **Source only** (not execute). Sets `DBT_DEMO_ROOT`, loads `.env` as defaults, exports DuckDB path, default target/project, docs ports, and paths to venv `dbt` / `python`. Idempotent via `DBT_DEMO_ENV_LOADED`. |
| **`bootstrap.sh`** | Full warehouse warm-up: seed integrity scan → `dbt_build_all.sh` with `DBT_TARGET=prod`. What CI / local pre-warm uses. Demo Part A only sources `setup.sh` live — not this. |
| **`scan_downloads.sh`** | Safety check on `data/seeds/*.csv`: SHA-256 pins (`checksums.sha256`), MIME/text type, no null bytes, UTF-8 CSV parse. No ClamAV required. Called by bootstrap / load_raw. |
| **`load_raw.sh`** | Wrapper: scan seeds, then run `load_raw.py` into `qa`/`prod` DuckDB (`DUCKDB_PROD_PATH` — same file for both). Usage: `./scripts/load_raw.sh [qa\|prod]`. |
| **`load_raw.py`** | Creates schema `raw` and `CREATE OR REPLACE TABLE` for each vendored CSV (`raw_customers`, `raw_orders`, …). Invoked by `load_raw.sh`. |
| **`dbt_build_all.sh`** | `load_raw.sh`, then for each of `mart_finance` / `mart_marketing` / `mart_operations`: `dbt deps` + `dbt build --target $DBT_TARGET`. |
| **`sql.sh`** | Ad-hoc SQL CLI against DuckDB. **Run, do not source.** Default read-only; `--write` for DDL/DML. `-t qa\|prod` (same file). No args → REPL. Calls `sql.py`. |
| **`sql.py`** | Python backend for `sql.sh`: one-shot SQL, stdin, or interactive REPL (`\q` to quit). |
| **`pull_state.sh`** | Capture baseline `manifest.json` into `state/<project>/` via `dbt compile --target-path` (default target `prod`). Prerequisite for `--defer` / Slim CI locally. |
| **`publish_state.sh`** | Runs `pull_state.sh` for all three domain projects. |
| **`slim_build.sh`** | Slim build: `dbt build --select state:modified+ --defer --state …` with `dev_schema` sandbox. Needs prior `pull_state.sh` + prod warehouse. |
| **`slim_build_all.sh`** | Slim-build every domain that already has `state/<project>/manifest.json`. |
| **`clone_state.sh`** | `dbt clone` from state into the defer sandbox schema (local relations pointing at prod without full rebuild). |

### Script dependency sketch

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

## Root-level files & folders

### Entry / environment

| Path | What it is |
|------|------------|
| **`setup.sh`** | Create `.venv` (uv, Python 3.11), `uv pip install -e ".[dev]"`, optional `pre-commit install`, create/refresh `.env` and `profiles.yml`, source `env.sh`, print `dbt --version`. **Source it:** `. ./setup.sh`. No dbt builds. |
| **`setup.py`** | setuptools package metadata; reads `requirements.json` for `install_requires` / `extras_require`. |
| **`requirements.json`** | Dependency pins: `dbt-duckdb`, `duckdb`; extras `dev` (ruff, pre-commit), `prefect`, `airflow` (stubs only — not installed by default setup). |
| **`dbt_docs.sh`** | Build (domains) or deps-only (`mart_combined`) → `docs generate` → `docs serve`. Ports from env (finance 8011, combined 8010, …). |
| **`.env.example`** | Template for local paths / defaults. Committed. |
| **`.env`** | Machine-local paths (`DBT_PROFILES_DIR`, `DUCKDB_PROD_PATH`, …). **Gitignored.** Created by `setup.sh`. |
| **`profiles.yml.example`** | dbt profile `dbt_demo` with `qa` + `prod` → same DuckDB file. Committed. |
| **`profiles.yml`** | Local copy of the profile. **Gitignored.** |

### Docs & agent guidance

| Path | What it is |
|------|------------|
| **`README.md`** | Human overview: purpose, quick start, CI, sustainable deployment, planned backlog. |
| **`AGENTS.md`** | Durable AI/agent instructions (stack, autonomy, commands). Prefer repo files over pretraining. |
| **`CLAUDE.md`** | One-liner: `@AGENTS.md` (Claude Code entry). |
| **`docs/`** | `STATUS.md` (handoff), `demo-agenda.md`, `dbt-feature-guide.md`, `defer.md`, `conventions.md`, this file. |

### Tooling / quality

| Path | What it is |
|------|------------|
| **`.pre-commit-config.yaml`** | Hooks: hygiene, Ruff, SQLFluff on `mart_*/models`, dbt-checkpoint. Install via `setup.sh` / `pre-commit install`. |
| **`ruff.toml`** | Ruff lint + format for Python (`scripts/`, `setup.py`). |
| **`.sqlfluff`** | SQLFluff for dbt SQL (DuckDB dialect, Jinja builtins, project macros). |
| **`.gitignore`** | Ignores `.env`, `profiles.yml`, DuckDB files, `target/`, `state/`, `.venv/`, etc. Keeps `data/seeds/` and `*.example`. |
| **`.cursorignore`** | Shrinks Cursor context (heavy trees: `target/`, `.venv/`, data artifacts). Not a security boundary. |

### Data & warehouse (non-dbt)

| Path | What it is |
|------|------------|
| **`data/seeds/`** | Vendored jaffle-shop CSVs + checksums / provenance. Committed. |
| **`data/prod.duckdb`** | Local warehouse file (qa + prod targets). **Gitignored** — created by load/bootstrap. |
| **`warehouse/ddl/`** | One-off warehouse DDL **outside** the dbt DAG (schemas, audit tables, grants notes). Apply once per env — not `on-run-start`. |
| **`warehouse/ddl/architectural_ddl.sql`** | Creates `audit` schema + `audit.dbt_model_hooks` (used by finance pre/post hooks). Example grants commented for real warehouses. |

### Domains, CI, orchestration (pointers only)

| Path | What it is |
|------|------------|
| **`mart_finance/`**, **`mart_marketing/`**, **`mart_operations/`** | Separate dbt projects (transform DAG). |
| **`mart_combined/`** | Docs-only project: all domains in one DAG. |
| **`.github/workflows/`** | `ci.yml`, `pre-commit.yml`, `orchestrate.yml` (stub). |
| **`orchestration/`** | Prefect + Airflow stubs (docs / optional extras). |
| **`state/`** | Local slim/defer manifests (`state/<mart_*>/`). **Gitignored**; filled by `pull_state.sh` or CI artifact. |

### Local / generated (usually ignore while reviewing)

| Path | Notes |
|------|--------|
| **`.venv/`** | uv virtualenv — do not commit. |
| **`dbt_demo.egg-info/`** | Editable-install metadata from `uv pip install -e`. |
| **`.ruff_cache/`** | Ruff cache. |
| **`.vscode/`** | Editor settings (local). |
| **`.user.yml`** | Local Cursor/user id noise — not part of the demo contract. |
| **`*.duckdb.wal`** | DuckDB write-ahead — gitignored. |

---

## `warehouse/ddl` vs `scripts/`

| Concern | Where |
|---------|--------|
| Bootstrap, load, slim, ad-hoc SQL | `scripts/` |
| One-shot schemas / audit / grants (not in DAG) | `warehouse/ddl/` |

Apply DDL example:

```bash
duckdb "$DUCKDB_PROD_PATH" < warehouse/ddl/architectural_ddl.sql
# or: ./scripts/sql.sh --write < warehouse/ddl/architectural_ddl.sql
```

---

## Quick “what should I open?” cheatsheet

| Goal | Open |
|------|------|
| First-time laptop setup | `setup.sh`, `.env.example`, `profiles.yml.example` |
| Full rebuild like CI | `scripts/bootstrap.sh` → `dbt_build_all.sh` |
| Seed trust / integrity | `scripts/scan_downloads.sh`, `data/seeds/` |
| Query the warehouse | `scripts/sql.sh` |
| Defer / Slim CI locally | `scripts/pull_state.sh`, `slim_build.sh`, `docs/defer.md` |
| Audit table / grants DDL | `warehouse/ddl/architectural_ddl.sql` |
| Agent / autonomy rules | `AGENTS.md` |
| Lint policy | `.pre-commit-config.yaml`, `ruff.toml`, `.sqlfluff` |
