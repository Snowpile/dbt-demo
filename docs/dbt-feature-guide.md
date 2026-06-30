# dbt feature guide / demo cheat-sheet

Demo-facing notes for the features showcased in this repo. Run all dbt commands
from inside a domain project (`cd projects/finance` etc.) after `source scripts/env.sh`.

---

## Incremental models — how they work

`finance_fct_order_revenue`, `marketing_fct_customer_orders`, and
`operations_fct_orders` are materialized `incremental`:

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='delete+insert',
    on_schema_change='append_new_columns'
) }}
```

- **First run / `--full-refresh`** — dbt builds the entire table from scratch.
- **Later runs** — the `{% if is_incremental() %}` branch adds a filter so only
  *new* rows are processed:

  ```sql
  {% if is_incremental() %}
    where ordered_at > (select coalesce(max(t.ordered_at), '1900-01-01') from {{ this }} as t)
  {% endif %}
  ```

- **`unique_key='order_id'`** — re-loaded orders replace the existing row instead
  of duplicating.
- **`incremental_strategy='delete+insert'`** — dbt deletes the keys in the new
  batch, then inserts the new rows (atomic swap of just the changed slice).
- **`on_schema_change='append_new_columns'`** — new upstream columns are appended
  to the target instead of erroring.

Why it matters: warehouse cost scales with *new* data, not full history (~62k orders).

Demo it:

```bash
dbt run --select finance_fct_order_revenue                 # incremental (no-op if no new rows)
dbt run --select finance_fct_order_revenue --full-refresh  # rebuild from scratch
```

---

## `--defer` + `--state` — how they work

`--defer` lets you build/test only the models you changed locally while
**referencing the production (or CI) versions** of everything else, instead of
rebuilding the whole DAG. dbt reads a previous run's artifacts (the *state*,
i.e. `manifest.json`) from a `--state` directory:

```bash
# 1. Capture a production manifest once (the "state" to compare/defer against).
dbt compile --target prod
cp target/manifest.json ../../state/finance/manifest.json

# 2. Work on a single model, deferring unchanged refs to prod, and only build
#    what changed vs. that state.
dbt build --select state:modified+ --defer --state ../../state/finance --favor-state
```

- **`state:modified+`** — select models that changed vs. the state manifest, plus
  their downstream children (`+`). Pairs with `state:new` for brand-new models.
- **`--defer`** — for any `ref()` to a model *not* selected this run, resolve it
  to the relation from the state manifest instead of building it locally.
- **`--favor-state`** — prefer the state version even if a local one exists.

Why it matters: this is the backbone of **Slim CI** — only build/test what a PR
touched, deferring the rest to the prod build. (CI wiring is intentionally
theoretical in this repo; see `docs/remaining-work.md` Phase 4.)

---

## Other showcased commands

```bash
# Custom + parametrized generic tests, singular tests, unit tests
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select test_type:unit

# run-operation: live row counts via run_query()
dbt run-operation audit_relations

# Source freshness (thresholds tuned for the static sample data)
dbt source freshness

# SCD2 snapshot of the product catalog
dbt snapshot

# Stored test failures (warn_high_margin_orders, not_empty_string) are queryable:
#   select * from main_dbt_test__audit.warn_high_margin_orders;

# Override a project var at runtime
dbt build --select finance_stg_orders --vars '{revenue_start_date: "2025-01-01"}'

# Docs (incl. {% docs %} blocks + the revenue_dashboard exposure)
dbt docs generate && dbt docs serve
```
