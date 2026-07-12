# dbt_demo

A self-contained **data engineering demo**: multiple **dbt Core** projects on **DuckDB**, wired
with a reproducible Python environment, CI, and docs. It runs entirely locally — no cloud
warehouse, no credentials — so you can clone it and build the full pipeline in a couple of
minutes.

## Purpose

Show a realistic, opinionated dbt setup end to end:

- Reproducible environment (`uv` + `setup.sh`) that CI uses verbatim
- A shared **raw** layer loaded from vendored CSVs into DuckDB
- Three independent dbt projects, one per business domain, sharing that raw data
- The full dbt feature surface (staging → intermediate → marts, tests, macros, snapshots,
  sources/freshness, incremental models, exposures, `--defer`/`--state`)
- CI that mirrors local work (pre-commit hooks + a full build)

It doubles as a live demo script (see `docs/demo-agenda.md`) and an AI-agent-friendly repo
(`AGENTS.md`, `.cursor/rules/`).

## What's in here

```
dbt-demo/
├── setup.sh                 # create venv + install deps + local config (fast, no builds)
├── scripts/
│   ├── env.sh               # shared env (paths, DuckDB targets, venv bin)
│   ├── scan_downloads.sh    # integrity-check seed CSVs (checksums, type, schema)
│   ├── load_raw.sh          # load seeds → DuckDB schema raw.*
│   ├── load_raw.py          #   (the actual loader)
│   ├── dbt_build_all.sh     # load raw + dbt build across all projects
│   └── bootstrap.sh         # scan → load raw → dbt build dev + prod (CI / local full build)
├── dbt_docs.sh              # build + generate + serve dbt docs for one project
├── data/seeds/              # vendored jaffle-shop CSVs (source of truth before DuckDB)
├── mart_finance/            # dbt project — revenue, margin, tax
├── mart_marketing/          # dbt project — customers, CLV, segments
├── mart_operations/         # dbt project — orders, stores, supplies
├── profiles.yml.example     # dbt profile (dev / staging / prod DuckDB files)
├── .github/workflows/       # CI: pre-commit (changed files) + full build
└── docs/                    # architecture, conventions, demo runbook, backlog
```

Each `mart_*` folder is a **separate dbt project** with its own `dbt_project.yml`, `models/`
(`staging/`, `intermediate/`, `marts/`), `macros/`, `tests/`, `seeds/`, and (finance) `snapshots/`.
All three read from the same `raw.*` tables.

## Requirements

- [`uv`](https://docs.astral.sh/uv/getting-started/installation/) (Python package manager)
- Python 3.11 (uv can install it)
- macOS / Linux / Windows (Git Bash or WSL for the `*.sh` scripts)

## Quick start

```bash
# 1. Environment (venv + config only; ~1 min). Source it so the venv/env stay active.
. ./setup.sh

# 2. (optional) Full local build — same as CI. For the live demo, run Part C commands one at a time instead.
./scripts/bootstrap.sh

# 3. (optional) Serve docs for one project in a second terminal.
./dbt_docs.sh mart_finance      # http://127.0.0.1:8011
```

To work in a single project:

```bash
cd mart_finance
dbt build --target dev
dbt test --select mart_finance_fct_order_revenue+   # example
```

## Data flow

```
data/seeds/*.csv  →  scripts/load_raw.py  →  raw.* (DuckDB)
                                              ↓
                     mart_<domain>/models  →  stg → int → fct/dim
```

dbt never reads the CSVs directly — `load_raw.py` loads them into the `raw` schema first, and
models reference them via `{{ source('raw', ...) }}`.

## Environments

One DuckDB file per target (paths come from `.env`, consumed by `profiles.yml`):

| Target | DuckDB file |
|--------|-------------|
| dev | `data/dev.duckdb` |
| staging | `data/staging.duckdb` |
| prod | `data/prod.duckdb` |

## CI

Two workflows run on every PR / push to `main`:

- **`pre-commit.yml`** — the same hooks as a local `git commit`, on changed files only
  (Ruff lint/format, SQLFluff, shellcheck, shfmt, gitleaks, …).
- **`ci.yml`** — `setup.sh` → `bootstrap.sh` (full build) → dbt-checkpoint structural checks.

## Conventions

- Model names: `{domain}_{layer}_{entity}` — e.g. `finance_stg_orders`, `finance_fct_order_revenue`.
- PK tests: `unique` + `not_null` on every mart primary key.
- See `docs/conventions.md` for the full set.

## More docs

| Topic | Path |
|-------|------|
| Architecture | `docs/architecture.md` |
| Conventions (naming, tests, SQL style) | `docs/conventions.md` |
| Live demo runbook | `docs/demo-agenda.md` |
| dbt mechanics (deep-dive) | `docs/dbt-feature-guide.md` |
| Backlog / remaining work | `docs/remaining-work.md` |
| GitHub / PR workflow | `docs/github.md` |
| AI agent instructions | `AGENTS.md` |

## Note on commits

Only humans commit and push in this repo. Automation and agents may stage changes and propose a
message, but never run `git commit` / `push` / `merge` / `rebase` / `reset`.
