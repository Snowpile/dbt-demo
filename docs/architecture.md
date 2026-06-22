# Architecture

## Overview

Three domain dbt projects on one **DuckDB** database. Shared **raw** layer from official Jaffle Shop sample CSVs.

| Domain | Focus | Key marts |
|--------|-------|-----------|
| `finance` | payments, revenue | `finance_fct_revenue`, `finance_dim_payment_method` |
| `marketing` | customers, engagement | `marketing_dim_customers`, `marketing_fct_customer_engagement` |
| `operations` | orders, fulfillment | `operations_fct_orders`, `operations_dim_fulfillment_status` |

## Data flow

```
data/seeds/*.csv  →  scripts/load_raw.py  →  raw.* (DuckDB)
                                              ↓
                         projects/<domain>/models  →  stg → int → fct/dim
```

## Orchestration

- **CI:** `.github/workflows/ci.yml` — scan seeds, load raw, `dbt build` all projects.
- **Local / cron:** `./scripts/dbt_build_all.sh` (e.g. `0 6 * * *` in crontab).

## Environments

| Target | DuckDB path | AI access |
|--------|-------------|-----------|
| dev | `data/dev.duckdb` | read/write OK |
| staging | `data/staging.duckdb` | ask first |
| prod | `data/prod.duckdb` | ask first |
