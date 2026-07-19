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
  incremental / incr-of-incr, hooks, shared `{% docs %}`, exposures, `--defer`/`--state`,
  config catalog under `mart_finance/models/_showcase/`)
- CI that mirrors local work, plus **orchestration stubs**: GitHub Actions, Prefect, and Airflow

It doubles as a live demo script (`docs/demo-agenda.md`, `DEMO_CHECKLIST.md`) and an
AI-agent-friendly repo (`AGENTS.md`, `.agents/skills/`).

## What's in here

```
dbt-demo/
├── setup.sh                 # venv + deps + local config (fast, no builds)
├── scripts/                 # env, scan, load_raw, bootstrap, slim/defer helpers, sql/architectural_ddl.sql
├── dbt_docs.sh              # docs server for one project
├── data/seeds/              # vendored jaffle-shop CSVs
├── mart_finance/            # revenue, margin, tax (+ headline dbt patterns)
├── mart_marketing/          # customers, CLV, segments
├── mart_operations/         # orders, stores, supplies
├── mart_combined/           # docs-only: all three domains in one DAG
├── orchestration/           # Prefect + Airflow stubs (docs only)
├── profiles.yml.example
├── .github/workflows/       # pre-commit, ci, slim-ci (dispatch), orchestrate (stub)
└── docs/                    # STATUS, demo-agenda, conventions, feature-guide, defer
```

Each `mart_*` is a **separate dbt project** (`dbt_project.yml`, `models/`, `macros/`, …).
All three read the same `raw.`* tables. **Every project** includes `dev_schema` +
`generate_schema_name` and shared docs in `models/docs.md` (`{{ doc() }}` in schema.yml).

## Requirements

- `[uv](https://docs.astral.sh/uv/getting-started/installation/)`
- Python 3.11
- macOS / Linux / Windows (Git Bash or WSL for `*.sh`)

## Quick start

```bash
. ./setup.sh                 # env only (~1 min); installs .[dev] only
./scripts/bootstrap.sh       # optional full build (same as CI)
./dbt_docs.sh mart_finance   # optional docs → http://127.0.0.1:8011
./dbt_docs.sh mart_combined  # optional: all domains in one DAG → :8010
./scripts/sql.sh "select 1"  # optional ad-hoc SQL vs data/dev.duckdb
```

### Single project

```bash
cd mart_finance
dbt build --target dev
dbt list --select tag:showcase
dbt show --select finance_stg_stores --limit 5
dbt source freshness
```

`dbt build` already **runs + tests** every selected node (models, seeds, snapshots, and the
generic/singular/unit tests attached to them in the DAG).

**Pre-mart gate** (build mid-layers before marts — tests are included in each `build`):

```bash
dbt build --select staging intermediate
dbt build --select marts
```

Use a separate `dbt test …` only for **custom / selective test runs that are not covered by that
build selection** (for example `dbt test --select test_type:singular` in the demo, or a one-off
test node you did not include in the prior `build`). Do not treat `dbt test` after `dbt build` on
the same select as required for ordinary model tests — those already ran.

## Data flow & environments

```
data/seeds/*.csv  →  scripts/load_raw.py  →  raw.* (DuckDB)
                                              ↓
                     mart_<domain>/models  →  stg → int → fct/dim
```


| Target  | DuckDB file           | Notes              |
| ------- | --------------------- | ------------------ |
| dev     | `data/dev.duckdb`     | Local iteration    |
| staging | `data/staging.duckdb` | Ask before writing |
| prod    | `data/prod.duckdb`    | Ask before writing |


DuckDB is **single-writer** per file — run domains/targets sequentially. Real platforms
swap the profile to Snowflake/BigQuery/etc.; project layout stays the same.

## CI & orchestration


| Path              | Role                                                   | Docs                                                                                                                                                            |
| ----------------- | ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pre-commit.yml`  | Lint changed files (Ruff, SQLFluff, …)                 | [GitHub Actions](https://docs.github.com/en/actions)                                                                                                            |
| `ci.yml`          | **main:** full bootstrap + upload `dbt-state` · **PR:** Slim CI (`state:modified+ --defer`) | `docs/defer.md` |
| `slim-ci.yml`     | Manual re-run of Slim CI against main artifact | `docs/defer.md` |
| `orchestrate.yml` | **Stub** scheduled/manual pipeline                     | [GitHub Actions](https://docs.github.com/en/actions) · [workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions) |
| `orchestration/prefect/` | **Stub** Python flows (Cloud or self-host) | [Prefect](https://docs.prefect.io/) · [self-host](https://docs.prefect.io/v3/manage/self-host) |
| `orchestration/airflow/` | **Stub** DAG scheduler (industry default) | [Airflow](https://airflow.apache.org/docs/) · [quick start](https://airflow.apache.org/docs/apache-airflow/stable/start.html) |


Optional Python deps for Prefect/Airflow are listed under `extras_require` in `requirements.json`
but **not** installed by `. ./setup.sh` (that only does `.[dev]`). See those stub READMEs to enable.

Remote: `[Snowpile/dbt-demo](https://github.com/Snowpile/dbt-demo)`. Branch → push → `gh pr create`.
**Only humans commit/push** (agents may stage and open PRs after commits).

## Conventions

- Model names: `{domain}_{layer}_{entity}`
- PK tests: `unique` + `not_null` on every mart PK
- Shared column docs: one `models/docs.md` per project → `{{ doc('field') }}` in `schema.yml`
- Details: `docs/conventions.md`

## Sustainable deployment (beyond this local demo)

This repo stays DuckDB + scripts on purpose. A durable production shape would add:

| Piece | Role |
|-------|------|
| **Dockerfile / compose** | Same `uv` + `requirements.json` runtime CI and laptops use; no “works on my machine” drift |
| **deployment.yml (or Helm/Terraform)** | Env-specific warehouse profiles, secrets, schedules — not committed credentials |
| **Orchestration** | Stubs in-repo: `orchestrate.yml` (GHA), `orchestration/prefect/`, `orchestration/airflow/` — pick one for prod schedules |
| **Warehouse one-offs** | DDL/grants in `scripts/sql/architectural_ddl.sql` (run once per env; not `on-run-start`) |
| **Warehouse profile** | Swap DuckDB for Snowflake/BigQuery/Postgres; keep `mart_*` projects unchanged |
| **Artifacts** | CI uploads `manifest.json` (+ `prod.duckdb` for DuckDB defer) from `main`; PRs Slim CI — `docs/defer.md` |
| **Docs hosting** | Local: `./dbt_docs.sh`. Prod may host `main` on Pages/S3 — not built here |

None of those are required to run the demo locally; they are the path when you graduate the
patterns off a laptop.

## More docs


| Topic                      | Path                           |
| -------------------------- | ------------------------------ |
| Session handoff / status   | `docs/STATUS.md`               |
| Demo walkthrough checklist | `DEMO_CHECKLIST.md` *(temp)*   |
| Live demo runbook          | `docs/demo-agenda.md`          |
| dbt feature map / CLI      | `docs/dbt-feature-guide.md`    |
| Defer / slim / clone       | `docs/defer.md`                |
| Naming / SQL style         | `docs/conventions.md`          |
| AI agent instructions      | `AGENTS.md`                    |
| Agent skills               | `.agents/skills/`              |
| Claude Code entry          | `CLAUDE.md` → `@AGENTS.md`     |
