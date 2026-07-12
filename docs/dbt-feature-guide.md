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

---

## Env-aware layered schemas (`generate_schema_name`)

`finance` overrides `macros/generate_schema_name.sql` with per-layer `+schema` in `dbt_project.yml`:

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

Slim CI in GitHub Actions is Phase 4 backlog (`docs/remaining-work.md`).

---

## Extras not shown live in the agenda

```bash
# Runtime var override (use `run`, not `build` — tighter date filters out unit-test fixtures)
dbt run --select finance_stg_orders --vars '{revenue_start_date: "2025-01-01"}'

# Query stored test failures
# select * from dev_dbt_test__audit.warn_high_margin_orders;
```
