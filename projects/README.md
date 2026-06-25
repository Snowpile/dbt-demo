# Domains: `finance`, `marketing`, `operations`

Shared **raw** layer (Jaffle Shop CSVs) → domain-specific **stg → int → fct/dim**.

```bash
./scripts/dbt_build_all.sh
./dbt_docs.sh finance
```

| Domain | Staging | Intermediate | Marts |
|--------|---------|--------------|-------|
| finance | payments, orders | order_payments | fct_revenue, dim_payment_method |
| marketing | customers, orders | customer_orders | dim_customers, fct_customer_engagement |
| operations | orders, customers | orders_enriched | fct_orders, dim_fulfillment_status |
