# Architecture

## Overview

Three domain dbt projects on **DuckDB** (one file per env). Shared **raw** layer from jaffle-shop CSVs.

| Domain | Focus | Key marts |
|--------|-------|-----------|
| `finance` | revenue, products | `finance_fct_order_revenue`, `finance_dim_product` |
| `marketing` | customers, engagement | `marketing_fct_customer_orders`, `marketing_dim_customers` |
| `operations` | orders, stores | `operations_fct_orders`, `operations_dim_stores` |

## Data flow

```
data/seeds/*.csv  →  scripts/load_raw.py  →  raw.* (DuckDB)
                                              ↓
                         mart_<domain>/models  →  stg → int → fct/dim
```

## Environments

| Target | DuckDB path | AI access |
|--------|-------------|-----------|
| dev | `data/dev.duckdb` | read/write OK |
| staging | `data/staging.duckdb` | ask first |
| prod | `data/prod.duckdb` | ask first |

## Orchestration

CI pipeline and local/cron commands: **Part A + B of `docs/demo-agenda.md`**.

## DuckDB note — demo scope only

DuckDB is **single-writer** per file. Run domains/targets sequentially, or use separate
`.duckdb` files. Real implementations target an enterprise warehouse (Snowflake, BigQuery,
Postgres) where concurrency is server-side; DuckDB keeps this demo free and local.
