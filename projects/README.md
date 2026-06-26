# Domains: `finance`, `marketing`, `operations`

Shared **raw** layer (Jaffle Shop star schema: orders, items, products, supplies, stores, customers) → domain-specific **stg → int → fct/dim**. Each domain has its own seed, macros, and a custom generic test, and demonstrates `view` + `table` + `ephemeral` + `incremental` materializations.

```bash
./scripts/dbt_build_all.sh   # load raw + seed + build all 3 domains
./dbt_docs.sh finance
```

Per domain: **≥3 staging (view)**, **6–9 intermediate** (mix of `ephemeral`/`view`/`table`), **3 marts** (≥1 `table` + 1 `incremental`).

| Domain | Focus | Key marts (★ = incremental) |
|--------|-------|------------------------------|
| finance | revenue, tax, BOM cost & margin | ★ `finance_fct_order_revenue`, `finance_fct_daily_revenue`, `finance_dim_product` |
| marketing | CLV, RFM segments, cohorts, channel, product affinity | ★ `marketing_fct_customer_orders`, `marketing_dim_customers`, `marketing_fct_product_affinity` |
| operations | order volume, store performance vs target, supply/perishable usage | ★ `operations_fct_orders`, `operations_fct_store_daily`, `operations_dim_stores` |

Seeds (loaded via `dbt seed` / `dbt build`): `finance_margin_targets`, `marketing_channels`, `operations_store_targets`.
