# dbt_demo — AI agent instructions

Data engineering repo. **Read this file first.** Prefer repo files over pretraining.
Works with Cursor, Claude Code, and other agents — durable context lives here and under `.agents/`, not vendor-specific rule folders.

> **Current state / where we left off:** see `docs/STATUS.md` (read at session start; **update at session end** — protocol in `.agents/skills/session-handoff/SKILL.md`).

## Session start / end

**On every new chat:**
1. Read `docs/STATUS.md` — especially **Resume here** and **Last session**.
2. Load other docs only when the task needs them (`docs/demo-agenda.md`, `DEMO_CHECKLIST.md` while demo prep is active).
3. Continue from **Resume here** without re-asking what was already decided.

**End of every session** (or when opening a fresh chat): update `docs/STATUS.md` so the next agent needs no conversation history. Full checklist: `.agents/skills/session-handoff/SKILL.md`.

**Fresh-chat prompt:** `Read docs/STATUS.md and continue.`

## Operating mode (token + autonomy)

- Minimize tokens: short replies, small diffs, no drive-by refactors or unsolicited docs.
- Be self-sufficient: run commands, read errors, fix and retry before asking.
- Load `docs/` only when the task needs depth — do not paste long specs into chat.
- **`@`-reference or name paths** — don't paste logs, whole files, or specs into chat.
- Scoped asks beat "review everything"; subagents for broad exploration (parent synthesizes).
- Multi-project dbt: always `cd mart_<domain>` before dbt commands.
- Fresh chat when context is long; resume via `docs/STATUS.md`.
- Token-lean detail: `.agents/skills/token-lean/SKILL.md`.
- dbt model work: `.agents/skills/dbt-models/SKILL.md` · Python: `.agents/skills/python/SKILL.md`.
- **No MCP** in this repo — terminal + repo files only (Claude Code and Cursor alike).

### Git: only the human commits/pushes

- **NEVER** run `git commit`, `git push`, `git merge`, `git rebase`, `git reset`, `git tag`, or any history-/remote-altering command — not even when asked.
- You **MAY** run read-only git (`status` / `diff` / `log` / `show`) and `git add` to prepare. Then stop: tell the user it's ready and propose a commit message.

### Autonomy matrix

| Allowed without asking | Never (human only) / Ask first |
|------------------------|--------------------------------|
| `./setup.sh`, `dbt deps`, local `dbt parse/compile/test/build` | **`git commit` / `push` / `merge` / `rebase` / `reset` — human only, never the AI** |
| Read-only git (`status`/`diff`/`log`), `git add` to prepare | Force-push, branch delete |
| Read-only SQL on **dev** DuckDB only | SQL on **staging** or **prod** |
| Create feature branches | Destructive warehouse DDL/DML |
| Edit CI / bash scripts | Changing secrets or prod credentials |
| `scripts/scan_downloads.sh`, `scripts/load_raw.sh`, `scripts/sql.sh` | Anything ambiguous on business logic |
| Open PRs via `gh` after human commits | — |

## Stack

| Layer | Choice |
|-------|--------|
| Warehouse | **DuckDB** (file per env) — **single-writer** per file; run domains/targets sequentially |
| Transform | **dbt Core** — `mart_{finance,marketing,operations}/` at repo root (+ `mart_combined/` docs-only DAG) |
| Orchestration (demo) | **GitHub Actions** (`ci.yml` + `orchestrate.yml` stub); **Prefect** / **Airflow** stubs under `orchestration/` — extras in `requirements.json`, not default install |
| Sample data | jaffle-shop seeds → `data/seeds/` → `raw.*` |
| Python | **uv** (`requirements.json`, `./setup.sh`); lint/format **Ruff** only |
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

CI on push to `main`: full bootstrap + upload **`dbt-state`** artifact (manifests + `prod.duckdb`).
CI on PR: download that artifact → `state:modified+ --defer` (Slim CI). Lint: `pre-commit.yml`.
Orchestration stubs (not the PR gate): `orchestrate.yml`, `orchestration/prefect/`, `orchestration/airflow/`.
Detail: `docs/defer.md`.

## Quick commands

```bash
. ./setup.sh                         # venv + config (~1 min)
./scripts/bootstrap.sh               # scan + load raw + dbt build dev + prod
./scripts/dbt_build_all.sh           # re-build only
./scripts/sql.sh "select 1"          # ad-hoc SQL (dev DuckDB; REPL if no args)
./dbt_docs.sh mart_finance           # docs :8011
./dbt_docs.sh mart_combined          # all-domain DAG :8010 (docs only)
```

## dbt conventions (summary)

- Names: `{domain}_{layer}_{entity}` — `stg` / `int` / `fct` / `dim`.
- Sources: `raw.raw_*` (see `data/seeds/PROVENANCE.md`).
- PK tests: `unique` + `not_null` on every mart PK.
- SQL: **SQLFluff**. Detail: `.agents/skills/dbt-models/SKILL.md`, `docs/conventions.md`.

## Python (summary)

- Deps via **uv** + `requirements.json` / `./setup.sh`.
- Lint + format: **Ruff only** (`ruff.toml`). Detail: `.agents/skills/python/SKILL.md`.

## Docs index

| Topic | Path |
|-------|------|
| Current status / handoff | `docs/STATUS.md` |
| Session handoff skill | `.agents/skills/session-handoff/SKILL.md` |
| Demo + pre-review checklist | `DEMO_CHECKLIST.md` *(remove after demo prep)* |
| Meeting / demo script | `docs/demo-agenda.md` |
| dbt feature map / CLI / mechanics | `docs/dbt-feature-guide.md` |
| Defer / slim / clone | `docs/defer.md` |
| Naming | `docs/conventions.md` |
| Token-lean skill | `.agents/skills/token-lean/SKILL.md` |
| Seed provenance | `data/seeds/PROVENANCE.md` |
