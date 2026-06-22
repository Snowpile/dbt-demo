# benderik — session summary

*Last updated: 2026-06-22. Read this tomorrow to pick up where we left off.*

## What this repo is

AI-friendly data engineering sandbox: **3 dbt projects** on **DuckDB**, sharing official **Jaffle Shop** sample data. Domains: `finance`, `marketing`, `operations`.

## Done ✓

| Area | Status |
|------|--------|
| AI config | `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/` (token-efficient) |
| Sample data | 3 CSVs from [dbt-labs/jaffle_shop_duckdb](https://github.com/dbt-labs/jaffle_shop_duckdb), SHA-256 pinned |
| Security | `scripts/scan_downloads.sh` (checksums, MIME, CSV parse) before every load |
| Raw layer | `scripts/load_raw.py` → DuckDB schema `raw` |
| dbt models | stg → int → fct/dim per domain; **49 tests passing** on dev |
| Tooling | `uv` + `uv.lock`, `scripts/dbt_build_all.sh` |
| CI | `.github/workflows/ci.yml` — scan → load → `dbt build` |
| Docs | `docs/architecture.md`, `docs/conventions.md`, `docs/github.md` |

### Model map

| Domain | Marts |
|--------|-------|
| finance | `finance_fct_revenue`, `finance_dim_payment_method` |
| marketing | `marketing_dim_customers`, `marketing_fct_customer_engagement` |
| operations | `operations_fct_orders`, `operations_dim_fulfillment_status` |

## Where we're at

- **Git:** repo initialized on `main`, **no commits yet**, **no GitHub remote**
- **Local:** `profiles.yml` exists (gitignored); `data/dev.duckdb` built and working
- **Verified:** `./scripts/dbt_build_all.sh` completes green locally

## Tomorrow — quick start

```bash
cd ~/Desktop/Contracting/benderik
uv sync
export DBT_PROFILES_DIR=$(git rev-parse --show-toplevel)
./scripts/dbt_build_all.sh
```

If fresh machine: `cp profiles.yml.example profiles.yml` and set absolute paths in `.env` (see `.env.example`).

## Still to do

### Must-do (to be “real”)

1. **First commit** — everything is untracked
2. **GitHub** — create `benderik` repo, add remote, push (`docs/github.md`)
3. **Auth** — SSH key or `gh auth login` for AI/human PR workflow

### Nice-to-have

4. **Cron** — schedule `./scripts/dbt_build_all.sh` if you want local runs beyond CI
5. **Staging/prod** — load raw into `data/staging.duckdb` / `data/prod.duckdb`; not tested yet
6. **Cleanup** — remove leftover `.gitkeep` in model folders; add `projects/**/logs/` to `.gitignore`
7. **Richer docs** — model/column descriptions in `schema.yml`; `dbt docs generate`
8. **Real data** — swap Jaffle Shop seeds when you have production sources

### Not planned (for now)

- Prefect (dropped; use GitHub Actions + bash/cron)
- MCP integrations
- Ingestion layer (sources assumed pre-loaded into `raw`)

## Key files

| Read first | Purpose |
|------------|---------|
| `AGENTS.md` | AI behavior + commands |
| `docs/github.md` | Push branches, open PRs |
| `data/seeds/PROVENANCE.md` | Data source + checksums |
| `projects/README.md` | Per-domain model layout |

## For AI (next session)

Say: *“Read `summary.md` and continue.”* — stack, conventions, and autonomy rules are in `AGENTS.md`. Do not commit unless asked.
