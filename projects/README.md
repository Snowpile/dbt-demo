# Domains: `finance`, `marketing`, `operations`

Shared **raw** layer (Jaffle Shop CSVs) → domain-specific **stg → int → fct/dim**.

```bash
export DBT_PROFILES_DIR=$(git rev-parse --show-toplevel)
./scripts/dbt_build_all.sh
```

| Domain | Staging | Intermediate | Marts |
|--------|---------|--------------|-------|
| finance | payments, orders | order_payments | fct_revenue, dim_payment_method |
| marketing | customers, orders | customer_orders | dim_customers, fct_customer_engagement |
| operations | orders, customers | orders_enriched | fct_orders, dim_fulfillment_status |
