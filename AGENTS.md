# benderik — AI agent instructions

Data engineering repo. **Read this file first.** Prefer repo files over pretraining.

> **Current state / where we left off:** see `docs/STATUS.md` (read it at the start of a session; update it at the end).

## Operating mode (token + autonomy)

- Minimize tokens: short replies, small diffs, no drive-by refactors or unsolicited docs.
- Be self-sufficient: run commands, read errors, fix and retry before asking.
- Load `docs/` only when the task needs depth — do not paste long specs into chat.
- **Only the human commits/pushes.** Never run `git commit`/`push`/`merge`/`rebase`/`reset` (even if asked); you may stage and propose a message, then hand off. See `.cursor/rules/core.mdc`.

### Autonomy matrix

| Allowed without asking | Never (human only) / Ask first |
|------------------------|--------------------------------|
| `./setup.sh`, `dbt deps`, local `dbt parse/compile/test/build` | **`git commit` / `push` / `merge` / `rebase` / `reset` — human only, never the AI** |
| Read-only git (`status`/`diff`/`log`), `git add` to prepare | Force-push, branch delete |
| Read-only SQL on **dev** DuckDB only | SQL on **staging** or **prod** |
| Create feature branches | Destructive warehouse DDL/DML |
| Edit CI / bash scripts | Changing secrets or prod credentials |
| `scripts/scan_downloads.sh`, `scripts/load_raw.sh` | Anything ambiguous on business logic |

## Stack

| Layer | Choice |
|-------|--------|
| Warehouse | **DuckDB** (file per env) |
| Transform | **dbt Core** — `projects/{finance,marketing,operations}/` |
| Orchestration | **GitHub Actions** + `scripts/dbt_build_all.sh` (cron optional) |
| Sample data | **dbt-labs/jaffle_shop_duckdb** seeds → `data/seeds/` → `raw.*` |
| Python | **uv** (`requirements.json`, `./setup.sh`) |
| Environments | **dev**, **staging**, **prod** dbt targets |
| Remote | **GitHub** `benderik` — see `docs/github.md` |

## Quick commands

```bash
./setup.sh                           # creates .env + .venv
./scripts/scan_downloads.sh          # integrity check before load
./scripts/load_raw.sh                # CSV → DuckDB schema raw
./scripts/dbt_build_all.sh           # load + dbt build all domains
./dbt_docs.sh marketing              # docs for one domain
```

## dbt conventions

- Names: `{domain}_{layer}_{entity}` — `stg` / `int` / `fct` / `dim`.
- Sources: `raw.raw_customers`, `raw.raw_orders`, `raw.raw_payments` (see `data/seeds/PROVENANCE.md`).
- PK tests: `unique` + `not_null` on every mart PK.

## Docs index

| Topic | Path |
|-------|------|
| Current status / handoff | `docs/STATUS.md` |
| Remaining work (backlog) | `docs/remaining-work.md` |
| AI practices (Cursor) | `docs/ai-practices-cursor.md` |
| AI practices (Claude) | `docs/ai-practices-claude.md` |
| GitHub / PRs | `docs/github.md` |
| Architecture | `docs/architecture.md` |
| Naming | `docs/conventions.md` |
| Seed provenance | `data/seeds/PROVENANCE.md` |
