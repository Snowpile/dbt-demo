# dbt_demo — AI agent instructions

Data engineering repo. **Read this file first.** Prefer repo files over pretraining.

> **Current state / where we left off:** see `docs/STATUS.md` (read at session start; **update at session end** — `.cursor/rules/session-handoff.mdc`).

## Operating mode (token + autonomy)

- Minimize tokens: short replies, small diffs, no drive-by refactors or unsolicited docs.
- Be self-sufficient: run commands, read errors, fix and retry before asking.
- Load `docs/` only when the task needs depth — do not paste long specs into chat.
- **Only the human commits/pushes.** Never run `git commit`/`push`/`merge`/`rebase`/`reset` (even if asked); you may stage and propose a message, then hand off. See `.cursor/rules/core.mdc`.
- Multi-project dbt: always `cd mart_<domain>` before dbt commands.
- Fresh chat when context is long; resume via `docs/STATUS.md`.
- **Note (pre-review #6):** fold `docs/ai-practices.md` into `.agents/skills/` + this file / `README.md`, then remove the standalone file.

### Autonomy matrix

| Allowed without asking | Never (human only) / Ask first |
|------------------------|--------------------------------|
| `./setup.sh`, `dbt deps`, local `dbt parse/compile/test/build` | **`git commit` / `push` / `merge` / `rebase` / `reset` — human only, never the AI** |
| Read-only git (`status`/`diff`/`log`), `git add` to prepare | Force-push, branch delete |
| Read-only SQL on **dev** DuckDB only | SQL on **staging** or **prod** |
| Create feature branches | Destructive warehouse DDL/DML |
| Edit CI / bash scripts | Changing secrets or prod credentials |
| `scripts/scan_downloads.sh`, `scripts/load_raw.sh` | Anything ambiguous on business logic |
| Open PRs via `gh` after human commits | — |

## Stack

| Layer | Choice |
|-------|--------|
| Warehouse | **DuckDB** (file per env) — **single-writer** per file; run domains/targets sequentially |
| Transform | **dbt Core** — `mart_{finance,marketing,operations}/` at repo root |
| Orchestration (demo) | **GitHub Actions** (`ci.yml` + `orchestrate.yml` stub); **Prefect** (`orchestration/prefect/`); **Airflow** (`orchestration/airflow/`) — docs stubs; deps in `requirements.json` extras, not default install |
| Sample data | jaffle-shop seeds → `data/seeds/` → `raw.*` |
| Python | **uv** (`requirements.json`, `./setup.sh`) |
| Environments | **dev** / **staging** / **prod** → `data/{dev,staging,prod}.duckdb` |
| Remote | GitHub [`Snowpile/dbt-demo`](https://github.com/Snowpile/dbt-demo) |

## Architecture (short)

```
data/seeds/*.csv  →  scripts/load_raw.py  →  raw.* (DuckDB)
                                              ↓
                     mart_<domain>/models  →  stg → int → fct/dim
```

| Domain | Focus | Example marts |
|--------|-------|----------------|
| finance | revenue, margin, tax | `finance_fct_order_revenue`, `finance_dim_product` |
| marketing | customers, CLV | `marketing_fct_customer_orders`, `marketing_dim_customers` |
| operations | orders, stores | `operations_fct_orders`, `operations_dim_stores` |

**Required in every project:** `vars.dev_schema` + `macros/generate_schema_name.sql` (defer sandbox). Shared field docs: `models/docs.md` + `{{ doc() }}`.

## GitHub / PR workflow

```bash
git remote set-url origin git@github-snowpile:Snowpile/dbt-demo.git   # or github.com:USER/dbt-demo.git
git checkout -b feat/my-change
# human commits …
git push -u origin HEAD
gh pr create --title "..." --body "..."
```

CI on PR/push to `main`: `pre-commit.yml` (changed-files lint) + `ci.yml` (setup → bootstrap → dbt-checkpoint). Orchestration stubs (not the PR gate): `.github/workflows/orchestrate.yml`, `orchestration/prefect/`, `orchestration/airflow/`.

## Quick commands

```bash
. ./setup.sh                         # venv + config (~1 min)
./scripts/bootstrap.sh               # scan + load raw + dbt build dev + prod
./scripts/dbt_build_all.sh           # re-build only
./dbt_docs.sh mart_finance           # docs :8011
```

## dbt conventions

- Names: `{domain}_{layer}_{entity}` — `stg` / `int` / `fct` / `dim`.
- Sources: `raw.raw_*` (see `data/seeds/PROVENANCE.md`).
- PK tests: `unique` + `not_null` on every mart PK.
- Python: **Ruff**; SQL: **SQLFluff**.

## Docs index

| Topic | Path |
|-------|------|
| Current status / handoff | `docs/STATUS.md` |
| Demo + pre-review checklist | `DEMO_CHECKLIST.md` |
| Meeting / demo script | `docs/demo-agenda.md` |
| Exhaustive dbt feature matrix | `docs/dbt-master-checklist.md` |
| dbt mechanics (deep-dive) | `docs/dbt-feature-guide.md` |
| Naming | `docs/conventions.md` |
| AI practices (interim) | `docs/ai-practices.md` |
| Seed provenance | `data/seeds/PROVENANCE.md` |
