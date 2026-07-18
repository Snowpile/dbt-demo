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

Add `relationships` when FKs are stable (see finance/ops/marketing `schema.yml`).

Custom generics live in `tests/generic/` (e.g. `not_negative`). Singular SQL tests in `tests/`.
Unit tests: `models/unit_tests.yml` (finance).

## Tags & selection

Layer tags come from `dbt_project.yml` (`staging`, `marts`, …). Model tags add demo markers
(`pre_hook_demo`, `showcase`). Prefer:

```bash
dbt build --select tag:marts
dbt list --select selector:finance_showcase   # mart_finance/selectors.yml
```

## SQL style

- CTEs over nested subqueries.
- Explicit column lists in final select.
- `{{ ref('finance_stg_orders') }}` — use full model name including domain prefix.

## Warehouse one-offs (DDL / grants)

Durable architectural SQL (create audit schemas/tables, grants, role setup) lives in
`scripts/sql/architectural_ddl.sql` — run once per environment, not on every dbt
invocation. `on-run-start` / `on-run-end` in `dbt_project.yml` are demo cold-start
only; remove them after the warehouse is initialized.
