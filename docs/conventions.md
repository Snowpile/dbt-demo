# Conventions

## Model naming

Pattern: `{domain}_{layer}_{entity}`

| Layer | Prefix | Materialization (default) |
|-------|--------|---------------------------|
| Staging | `stg` | view |
| Intermediate | `int` | view or ephemeral |
| Fact | `fct` | table |
| Dimension | `dim` | table |

Examples for domain `finance`:

- `finance_stg_orders`
- `finance_int_orders_enriched`
- `finance_fct_revenue`
- `finance_dim_customers`

## Columns

- Primary key: `{entity}_id` (e.g. `order_id` on orders models).
- Timestamps: `{event}_at` in UTC unless documented otherwise.
- Booleans: `is_{condition}` (e.g. `is_active`).

## Tests (required)

On every PK: `unique`, `not_null`.

Add relationship tests when FKs are stable.

## SQL style

- CTEs over nested subqueries.
- Explicit column lists in final select.
- `{{ ref('finance_stg_orders') }}` — use full model name including domain prefix.
