# dbt feature guide (deep-dive reference)

Mechanics behind the live demo. **Commands and order of operations:** `docs/demo-agenda.md` Part C.
Run dbt from inside a domain project (`cd mart_finance`) after `source scripts/env.sh`.

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

### Incremental-of-incrementals (finance)

When a child incremental depends on **more than one** incremental parent:

1. `finance_int_orders_delta` + `finance_int_order_items_delta` — incremental parents
2. `finance_int_changed_order_ids` — unions `order_id`s from both
3. `finance_fct_order_revenue` — on incremental runs, joins to that ID set (plus watermark)

That keeps the child from re-scanning wide joins just to discover what changed.

### Hooks (finance — split across models)

- **Project:** `on-run-start` creates `audit.dbt_model_hooks`; `on-run-end` logs.
- **pre_hook** on `finance_fct_order_revenue` — retention `DELETE` + audit insert.
- **post_hook** on `finance_fct_daily_revenue` — `UPDATE loaded_at` + audit insert.

Separate models so the demo can show each hook type without stacking both on one node.

---

## Env-aware layered schemas (`generate_schema_name`)

**All three projects** override `macros/generate_schema_name.sql` with per-layer `+schema`
in `dbt_project.yml` and declare `vars.dev_schema` (required pattern):

| Layer | `+schema` | dev target | prod / staging |
|---|---|---|---|
| staging | `source_data` | `dev_source_data` | `source_data` |
| intermediate | `transform` | `dev_transform` | `transform` |
| marts | `mart` | `dev_mart` | `mart` |

- **prod / staging / qa** → bare layer names.
- **dev** → env-prefixed (`dev_source_data`, …) so local builds can't clobber prod.
- **`dev_schema` var** — when set (`--vars '{"dev_schema":"dev"}'`), flattens everything into
  one schema (used with `--defer` so branch edits stay sandboxed).

---

## `--defer` + `--state`

**Prerequisite:** prod fully built (`DBT_TARGET=prod ./scripts/dbt_build_all.sh`).

| Flag / selector | Role |
|---|---|
| `state:modified+` | Changed vs. state manifest + downstream children |
| `--defer` | Unselected `ref()`s resolve to state manifest relations |
| `--state /tmp/dbt` | Directory containing baseline `manifest.json` |
| `--target-path /tmp/dbt` | Write baseline manifest outside working `target/` |
| `--vars '{"dev_schema":"dev"}'` | Sandbox schema for models you *did* build |
| `--target prod` (both steps) | DuckDB catalog must match (`prod.duckdb` → catalog `prod`) |

Slim CI in GitHub Actions is Phase 2+ backlog (`DEMO_CHECKLIST.md`).

---

## Extras not shown live in the agenda

```bash
# Runtime var override (use `run`, not `build` — tighter date filters out unit-test fixtures)
dbt run --select finance_stg_orders --vars '{revenue_start_date: "2025-01-01"}'

# Query stored test failures
# select * from dev_dbt_test__audit.warn_high_margin_orders;
```
