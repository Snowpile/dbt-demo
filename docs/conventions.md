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

## Documentation (`{% docs %}` vs `schema.yml`)

Prefer **shared** field docs in `models/docs.md` + `{{ doc('field') }}` in `schema.yml` when the
column means the **same thing** across models (e.g. `order_id` everywhere is the order key).

**When the same column name means different things in different models**, do **not** force a
shared `{% docs %}` block — put a model-specific `description:` on that column in `schema.yml`
(or a uniquely named doc block like `status__orders` vs `status__shipments`). Shared docs are
for identical semantics only; divergent meanings stay inline in YAML.

| Situation | Where the description lives |
|-----------|----------------------------|
| Same name, same meaning across tables | `models/docs.md` → `{{ doc('col') }}` |
| Same name, **different** meaning | Inline `description:` under that model in `schema.yml` |
| One-off model narrative | `{% docs model_name %}` in `docs.md` or inline model `description:` |

## Tests (required)

On every PK: `unique`, `not_null`.

Add relationship tests when FKs are stable.

## SQL style

- CTEs over nested subqueries.
- Explicit column lists in final select.
- `{{ ref('finance_stg_orders') }}` — use full model name including domain prefix.
