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
- Full dbt feature surface (stg → int → marts, tests, macros, snapshots, sources/freshness,
  incremental / incr-of-incr, hooks, shared `{% docs %}`, exposures, `--defer`/`--state`)
- CI that mirrors local work, plus **orchestration stubs** (GitHub Actions + Prefect) — not Airflow

It doubles as a live demo script (`docs/demo-agenda.md`, `DEMO_CHECKLIST.md`) and an
AI-agent-friendly repo (`AGENTS.md`, `.cursor/rules/`).

## What's in here

```
dbt-demo/
├── setup.sh                 # venv + deps + local config (fast, no builds)
├── scripts/                 # env, scan, load_raw, dbt_build_all, bootstrap
├── dbt_docs.sh              # docs server for one project
├── data/seeds/              # vendored jaffle-shop CSVs
├── mart_finance/            # revenue, margin, tax (+ headline dbt patterns)
├── mart_marketing/          # customers, CLV, segments
├── mart_operations/         # orders, stores, supplies
├── prefect/                 # Prefect orchestration stub (docs only)
├── profiles.yml.example
├── .github/workflows/       # pre-commit, ci, orchestrate (stub)
└── docs/                    # STATUS, demo-agenda, conventions, feature checklists
```

Each `mart_*` is a **separate dbt project** (`dbt_project.yml`, `models/`, `macros/`, …).
All three read the same `raw.*` tables. **Every project** includes `dev_schema` +
`generate_schema_name` and shared docs in `models/docs.md` (`{{ doc() }}` in schema.yml).

## Requirements

- [`uv`](https://docs.astral.sh/uv/getting-started/installation/)
- Python 3.11
- macOS / Linux / Windows (Git Bash or WSL for `*.sh`)

## Quick start

```bash
. ./setup.sh                 # env only (~1 min)
./scripts/bootstrap.sh       # optional full build (same as CI)
./dbt_docs.sh mart_finance   # optional docs → http://127.0.0.1:8011
```

Single project:

```bash
cd mart_finance
dbt build --target dev
# Pre-mart gate (demo pattern):
dbt build --select staging intermediate
dbt test  --select staging intermediate
dbt build --select marts
```

## Data flow & environments

```
data/seeds/*.csv  →  scripts/load_raw.py  →  raw.* (DuckDB)
                                              ↓
                     mart_<domain>/models  →  stg → int → fct/dim
```

| Target | DuckDB file | Notes |
|--------|-------------|-------|
| dev | `data/dev.duckdb` | Local iteration |
| staging | `data/staging.duckdb` | Ask before writing |
| prod | `data/prod.duckdb` | Ask before writing |

DuckDB is **single-writer** per file — run domains/targets sequentially. Real platforms
swap the profile to Snowflake/BigQuery/etc.; project layout stays the same.

## CI & orchestration

| Workflow | Role |
|----------|------|
| `pre-commit.yml` | Lint changed files (Ruff, SQLFluff, …) |
| `ci.yml` | `setup.sh` → `bootstrap.sh` → dbt-checkpoint (PR gate) |
| `orchestrate.yml` | **Stub** scheduled/manual pipeline (non-Airflow orchestrator) |
| `prefect/` | **Stub** docs-only alternative orchestrator |

Remote: [`Snowpile/dbt-demo`](https://github.com/Snowpile/dbt-demo). Branch → push → `gh pr create`.
**Only humans commit/push** (agents may stage and open PRs after commits).

## Conventions

- Model names: `{domain}_{layer}_{entity}`
- PK tests: `unique` + `not_null` on every mart PK
- Shared column docs: one `models/docs.md` per project → `{{ doc('field') }}` in `schema.yml`
- Details: `docs/conventions.md`

## How we use `docs/dbt-master-checklist.md`

It is the exhaustive **dbt feature coverage catalog** for finishing this *repo as a reference*
(✅ / 🔶 / ⬜) — “have we demonstrated X in dbt yet?”
Day-of **meeting** execution lives in `DEMO_CHECKLIST.md` and `docs/demo-agenda.md`.
Those are different: master checklist = product coverage; demo checklist = talk track.

## Sustainable deployment (beyond this local demo)

This repo stays DuckDB + scripts on purpose. A durable production shape would add:

| Piece | Role |
|-------|------|
| **`Dockerfile` / compose** | Same `uv` + `requirements.json` runtime CI and laptops use; no “works on my machine” drift |
| **`deployment.yml` (or Helm/Terraform)** | Env-specific warehouse profiles, secrets, schedules — not committed credentials |
| **Orchestration** | Prefer the stubs here: GitHub Actions `orchestrate.yml` and/or Prefect — not Airflow-first |
| **Warehouse profile** | Swap DuckDB for Snowflake/BigQuery/Postgres; keep `mart_*` projects unchanged |
| **Artifacts** | Persist `manifest.json` from `main` for Slim CI (`--defer --state`) |
| **Docs hosting** | `dbt docs generate` → GitHub Pages / S3 / internal static host |

None of those are required to run the demo locally; they are the path when you graduate the
patterns off a laptop.

## More docs

| Topic | Path |
|-------|------|
| Session handoff / status | `docs/STATUS.md` |
| Demo walkthrough checklist | `DEMO_CHECKLIST.md` |
| Live demo runbook | `docs/demo-agenda.md` |
| dbt feature matrix | `docs/dbt-master-checklist.md` |
| dbt mechanics | `docs/dbt-feature-guide.md` |
| Naming / SQL style | `docs/conventions.md` |
| AI agent instructions | `AGENTS.md` |
