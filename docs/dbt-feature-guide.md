# dbt feature guide

Mechanics and **where to find** each pattern in this repo. Day-of commands: `docs/demo-agenda.md`.
Defer/slim/clone: `docs/defer.md`. Naming: `docs/conventions.md`.

Run dbt from inside a domain project (`cd mart_finance`) after `. ./setup.sh`.

---

## Feature map (by path)

| Area | Where |
|------|--------|
| Layer defaults (materialized, schema, tags, meta, node_color, persist_docs) | `mart_*/dbt_project.yml` |
| Config catalog (enabled, merge, append, delete+insert, microbatch, contract, versions, quote, custom strategy, indexes) | `mart_finance/models/_showcase/` |
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

**Prefer `merge` (upserts) or `append` (insert-only).** Domain order facts use `merge`.
`delete+insert` still works and has a showcase example, but it is usually the weaker
default when the adapter supports merge.

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
```

- **First run / `--full-refresh`** — full table from scratch.
- **Later runs** — `{% if is_incremental() %}` filters to new/changed rows only.
- **`unique_key`** — required for `merge` / `delete+insert` so re-loaded keys replace.
- **`on_schema_change='append_new_columns'`** — new upstream columns append instead of erroring.

### Strategies in this repo (DuckDB)

| Strategy | When to use | Example |
|----------|-------------|---------|
| **`merge`** | Upserts by `unique_key` (default for facts/dims) | Domain order facts; `finance_showcase_store_scd` |
| **`append`** | Insert-only event / audit logs (no key updates) | `finance_showcase_order_log` |
| `delete+insert` | Delete matching keys then insert — simpler than merge on some warehouses; usually prefer merge here | `finance_showcase_delete_insert` |
| `microbatch` | Large time-series: dbt splits the run into time windows | `finance_showcase_orders_mb` — **`concurrent_batches=false`** on file DuckDB |
| `custom` | You own the DML via `get_incremental_<name>_sql` | `finance_showcase_custom_incr` + `macros/get_incremental_custom_sql.sql` |

`insert_overwrite` is warehouse-specific (e.g. BigQuery partitions) — not used on DuckDB.

**Talk track:** open `_showcase/` for append + merge side-by-side; domain C3 path uses merge
on the incremental-of-incrementals child. Microbatch / custom details below.

### Microbatch (`finance_showcase_orders_mb`)

Unlike `merge` / `append`, you do **not** write `{% if is_incremental() %}` filters.
dbt decides the time windows and runs **one query per batch**.

| Config | Role in this model |
|--------|--------------------|
| `event_time='ordered_at'` | Timestamp column that defines batch boundaries |
| `begin='2026-01-01'` | Earliest batch on first run / `--full-refresh` |
| `batch_size='month'` | Window grain: `hour` \| `day` \| `month` \| `year` |
| `lookback=0` | Reprocess N prior batches for late data (default is often `1`) |
| `concurrent_batches=false` | **Required on file DuckDB** (single-writer). Warehouses that allow parallel writers can leave this on. |

**What happens on a run:**

1. dbt computes which batches are needed (from `begin` / last bookmark / `lookback` / “now”).
2. For each batch it builds a filtered query (auto-filters upstream `ref`/`source` that declare `event_time`).
3. Each batch is applied with microbatch DML (time-window replace — think delete+insert for that window, not a row-level `unique_key` merge).
4. Failed batches can be retried independently; backfill a range with
   `dbt run --select finance_showcase_orders_mb --event-time-start … --event-time-end …`.

**When to use:** large chronologically ordered facts where one giant incremental query is
slow or fragile. **When not:** small dims, non-time-keyed upserts → use `merge` / `append`.

Upstream parents should also set `event_time` on the same column when you want auto-filtering
of `ref()` inputs (see [dbt microbatch docs](https://docs.getdbt.com/docs/build/incremental-microbatch)).

### Custom strategy (`finance_showcase_custom_incr`)

Built-in strategies are just macros named `get_incremental_<strategy>_sql`. A **custom**
strategy is the same hook with your name:

1. Set `incremental_strategy='custom'` on the model (any name works — here `custom`).
2. Define `macros/get_incremental_custom_sql.sql` → macro `get_incremental_custom_sql(arg_dict)`.
3. dbt compiles the model SELECT into a temp relation, then calls your macro to emit the
   DML that writes temp → target. `arg_dict` includes `target_relation`, `temp_relation`,
   `unique_key`, `dest_columns`, `incremental_predicates`, etc.

This repo’s macro is intentionally thin — it **reuses merge**:

```sql
{% macro get_incremental_custom_sql(arg_dict) %}
  {{ return(get_incremental_merge_sql(arg_dict)) }}
{% endmacro %}
```

**Real-world uses:** warehouse-specific merge (null-safe keys, soft-delete flags),
extra audit columns in the merge, or wrapping a package strategy under a project-local name.
dbt does not validate the strategy name — if the macro is missing, the run fails.

You still write normal incremental SELECT logic (`is_incremental()` filters, `unique_key`)
when the underlying DML expects them; the custom piece is **how** rows land in the target,
not how the SELECT is built.

### Incremental-of-incrementals (finance)

1. `finance_int_orders_delta` + `finance_int_order_items_delta` — incremental parents
2. `finance_int_changed_order_ids` — unions `order_id`s from both
3. `finance_fct_order_revenue` — on incremental runs, joins to that ID set (plus watermark)

### Hooks (finance — split across models)

- **Project:** `on-run-start` creates `audit.dbt_model_hooks`; `on-run-end` logs.
  Demo cold-start only — **after init, remove** `on-run-start` / `on-run-end`.
  One-off DDL/grants: `scripts/sql/architectural_ddl.sql` (not every invocation).
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
