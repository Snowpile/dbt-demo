# dbt feature guide

Mechanics and **where to find** each pattern in this repo. Day-of commands: `docs/demo-agenda.md`.
Defer/slim/clone: `docs/defer.md`. Naming: `docs/conventions.md`.

Run dbt from inside a domain project (`cd mart_finance`) after `. ./setup.sh`.

---

## Feature map (by path)

| Area | Where |
|------|--------|
| Layer defaults (materialized, schema, tags, meta, node_color, persist_docs) | `mart_*/dbt_project.yml` |
| Config catalog (enabled, merge, append, microbatch, contract, versions, quote, custom strategy, indexes) | `mart_finance/models/_showcase/` |
| Incr-of-incr + pre_hook | `finance_fct_order_revenue` + `finance_int_*_delta` |
| post_hook | `finance_fct_daily_revenue` |
| Shared `{% docs %}` | `mart_*/models/docs.md` → `{{ doc() }}` in `schema.yml` |
| Macros | `cents_to_dollars`, `generate_schema_name`, `audit_relations`, `get_incremental_custom_sql` |
| Package | `packages.yml` → `dbt_utils` (tests + `generate_surrogate_key`) |
| Tests | generic / singular / custom generic / unit (`unit_tests.yml`) / freshness |
| Snapshot | `mart_finance/snapshots/finance_snapshot_products.yml` |
| Exposure | `mart_finance/models/exposures.yml` |
| Analysis | `mart_finance/analyses/revenue_by_store_analysis.sql` |
| Groups / access | `mart_finance/models/groups.yml` + showcase models |
| Named selectors | `mart_finance/selectors.yml` |
| Docs site (local only) | `./dbt_docs.sh mart_finance` — branch vs `main`; no Pages deploy |
| Defer / state / clone | `scripts/pull_state.sh`, `slim_build.sh`, `clone_state.sh` |

---

## CLI cheat sheet

```bash
cd mart_finance

dbt debug                          # connection / profiles
dbt parse                          # validate project (CI)
dbt deps                           # install packages.yml
dbt list --select tag:showcase     # list nodes (also: path:, +, source:)
dbt list --select selector:finance_marts
dbt compile --select finance_stg_orders
dbt show --select finance_stg_stores --limit 5
dbt build --select staging intermediate
dbt build --select marts
dbt test --select test_type:singular
dbt seed                           # reference seeds (bulk raw = ../scripts/load_raw.sh)
dbt snapshot
dbt source freshness
dbt run-operation audit_relations
dbt clean                          # wipe target/ + dbt_packages/
# after a failed build:
# dbt retry
```

Selection examples: `--select model_name`, `tag:finance`, `path:models/_showcase`,
`+finance_fct_daily_revenue+`, `source:raw.raw_orders`, `state:modified+` (needs `--state`).

---

## Incremental models

`finance_fct_order_revenue` (and marketing/operations equivalents) use:

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='delete+insert',
    on_schema_change='append_new_columns'
) }}
```

- **First run / `--full-refresh`** — full table from scratch.
- **Later runs** — `{% if is_incremental() %}` filters to new rows only.
- **`unique_key`** — re-loaded keys replace, don't duplicate.
- **`delete+insert`** — delete changed keys, insert new batch.
- **`on_schema_change='append_new_columns'`** — new upstream columns append instead of erroring.

### Strategies in this repo (DuckDB)

| Strategy | Example |
|----------|---------|
| `delete+insert` | domain order facts |
| `merge` | `finance_showcase_store_scd` |
| `append` | `finance_showcase_order_log` |
| `microbatch` | `finance_showcase_orders_mb` — **`concurrent_batches=false`** on file DuckDB |
| `custom` | `get_incremental_custom_sql` → `finance_showcase_custom_incr` |

`insert_overwrite` is warehouse-specific (e.g. BigQuery) — not used here.

### Incremental-of-incrementals (finance)

1. `finance_int_orders_delta` + `finance_int_order_items_delta` — incremental parents
2. `finance_int_changed_order_ids` — unions `order_id`s from both
3. `finance_fct_order_revenue` — on incremental runs, joins to that ID set (plus watermark)

### Hooks (finance — split across models)

- **Project:** `on-run-start` creates `audit.dbt_model_hooks`; `on-run-end` logs.
- **pre_hook** on `finance_fct_order_revenue` — retention `DELETE` + audit insert.
- **post_hook** on `finance_fct_daily_revenue` — `UPDATE loaded_at` + audit insert.

---

## Env-aware layered schemas (`generate_schema_name`)

**All three projects** override `macros/generate_schema_name.sql` with per-layer `+schema`
in `dbt_project.yml` and declare `vars.dev_schema` (required pattern):

| Layer | `+schema` | dev target | prod / staging |
|---|---|---|---|
| staging | `source_data` | `dev_source_data` | `source_data` |
| intermediate | `transform` | `dev_transform` | `transform` |
| marts | `mart` | `dev_mart` | `mart` |
| showcase (finance) | `showcase` | `dev_showcase` | `showcase` |

- **prod / staging** → bare layer names.
- **dev** → env-prefixed so local builds can't clobber prod.
- **`dev_schema` var** — when set (`--vars '{"dev_schema":"dev"}'`), flattens into one sandbox
  schema for `--defer` builds.

Project vars example: `revenue_start_date` on `finance_stg_orders` (override with `--vars`).

---

## `--defer` + `--state`

**Full runbook:** `docs/defer.md`.

Optional Actions demo: `.github/workflows/slim-ci.yml` (`workflow_dispatch`). PR gate stays full bootstrap.

---

## Docs (local only)

`./dbt_docs.sh` runs build → `docs generate` → `docs serve`. Use it on a feature branch to
compare DAG/descriptions against `main`. Hosting `main` on Pages/S3 is a production pattern
(README “Sustainable deployment”) — not implemented here.

Do **not** put `{{ doc() }}` inside `{% docs %}` block bodies (breaks parse).

---

## DuckDB limits (deliberate N/A)

Documented in `dbt_project.yml` comments / showcase:

| Config | Why skipped |
|--------|-------------|
| `grants` | no role model like Snowflake/BQ |
| `partition_by` / `cluster_by` | warehouse-native elsewhere |
| `database` cross-db | single-file DuckDB |
| `materialized_view` | not in dbt-duckdb materializations |

File DuckDB is **single-writer** — run domains/targets sequentially; microbatch needs
`concurrent_batches=false`.

---

## Out of scope for this demo

- Extra packages (`dbt_expectations`, `audit_helper`, `codegen`) — `dbt_utils` is enough
- MetricFlow / semantic layer YAML (MetricFlow may be installed transitively; no models here)
- Private package pattern, IDE extension notes, `dbt-jsonschema`
- Uploading `manifest.json` from `main` as a CI artifact (local `pull_state.sh` covers the lesson)
- Deployed docs sites

---

## Extras

```bash
# Runtime var override (use `run`, not `build` — tighter date filters out unit-test fixtures)
dbt run --select finance_stg_orders --vars '{revenue_start_date: "2025-01-01"}'

# Query stored test failures
# select * from dev_dbt_test__audit.warn_high_margin_orders;

# Compile an analysis (not in the DAG)
dbt compile --select revenue_by_store_analysis
```
