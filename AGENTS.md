# benderik — AI agent instructions

Data engineering repo. **Read this file first.** Prefer repo files over pretraining.

## Operating mode (token + autonomy)

- Minimize tokens: short replies, small diffs, no drive-by refactors or unsolicited docs.
- Be self-sufficient: run commands, read errors, fix and retry before asking.
- Load `docs/` only when the task needs depth — do not paste long specs into chat.
- Do not commit unless explicitly asked. Push only when opening a PR or when asked.

### Autonomy matrix

| Allowed without asking | Ask first |
|------------------------|-----------|
| `uv sync`, `dbt deps`, local `dbt parse/compile/test/build` | Commits, force-push, branch delete |
| Read-only SQL on **dev** DuckDB only | SQL on **staging** or **prod** |
| Create feature branches, push, open PRs via `gh` | Destructive warehouse DDL/DML |
| Edit CI / bash scripts | Changing secrets or prod credentials |
| `scripts/scan_downloads.sh`, `scripts/load_raw.sh` | Anything ambiguous on business logic |

## Stack

| Layer | Choice |
|-------|--------|
| Warehouse | **DuckDB** (file per env) |
| Transform | **dbt Core** — `projects/{finance,marketing,operations}/` |
| Orchestration | **GitHub Actions** + `scripts/dbt_build_all.sh` (cron optional) |
| Sample data | **dbt-labs/jaffle_shop_duckdb** seeds → `data/seeds/` → `raw.*` |
| Python | **uv** (`pyproject.toml`, commit `uv.lock`) |
| Environments | **dev**, **staging**, **prod** dbt targets |
| Remote | **GitHub** `benderik` — see `docs/github.md` |

## Quick commands

```bash
export DBT_PROFILES_DIR=$(git rev-parse --show-toplevel)
./scripts/scan_downloads.sh          # integrity check before load
./scripts/load_raw.sh dev            # CSV → DuckDB schema raw
./scripts/dbt_build_all.sh           # load + dbt build all domains
cd projects/finance && uv run dbt build
```

## dbt conventions

- Names: `{domain}_{layer}_{entity}` — `stg` / `int` / `fct` / `dim`.
- Sources: `raw.raw_customers`, `raw.raw_orders`, `raw.raw_payments` (see `data/seeds/PROVENANCE.md`).
- PK tests: `unique` + `not_null` on every mart PK.

## Docs index

| Topic | Path |
|-------|------|
| GitHub / PRs | `docs/github.md` |
| Architecture | `docs/architecture.md` |
| Naming | `docs/conventions.md` |
| Seed provenance | `data/seeds/PROVENANCE.md` |
