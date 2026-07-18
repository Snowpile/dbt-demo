{#
  Shared column + model documentation for mart_finance.
  Reuse via {{ doc('...') }} in schema.yml so one definition covers many tables
  ONLY when the column means the same thing everywhere.

  Same name, different meaning? → inline description in schema.yml
  (see docs/conventions.md → Documentation).

  Applicable models (column docs — shared semantics):
    order_id, customer_id, store_id, ordered_at, order_date
      → finance_stg_orders, finance_fct_order_revenue, deltas, …
    sku → finance_stg_order_items, finance_int_order_items_delta, …
    gross_margin_pct → finance_fct_order_revenue
#}

{% docs order_id %}
Surrogate key for a single customer order. Stable across staging, intermediate, and mart
layers — reuse this doc block wherever `order_id` appears.
{% enddocs %}

{% docs customer_id %}
Identifier for the purchasing customer. Joins to customer dimensions in marketing;
finance keeps it as a degenerate dimension on order facts.
{% enddocs %}

{% docs ordered_at %}
Timestamp when the order was placed (UTC). Used for incremental watermarks and
source freshness (`loaded_at_field` on `raw.raw_orders`).
{% enddocs %}

{% docs order_date %}
Calendar date of `ordered_at` (UTC). Prefer this for daily aggregations.
{% enddocs %}

{% docs sku %}
Stock-keeping unit / product code. Joins order line items to the product catalog and BOM.
{% enddocs %}

{% docs store_id %}
Store / location identifier. Joins to store attributes (tax rate, targets).
{% enddocs %}

{% docs gross_margin_pct %}
Gross profit divided by subtotal, rounded to 4 decimals. Ratio in `[0, 1]`
(guarded by the `accepted_range` custom generic test).
{% enddocs %}

{% docs finance_fct_order_revenue %}
Incremental order-grain revenue fact.

**Incremental strategy:** `unique_key='order_id'`, `merge`,
`on_schema_change='append_new_columns'`. Prefer `merge` / `append` over `delete+insert`
(see `docs/dbt-feature-guide.md` and `models/_showcase/`).

**Incremental-of-incrementals:** On incremental runs, filters to `order_id`s from
`finance_int_changed_order_ids` (union of keys from two upstream incremental parents).

**Hooks:** This model has the **pre_hook** (retention DELETE + audit). The **post_hook**
(UPDATE `loaded_at` + audit) lives on `finance_fct_daily_revenue` so each hook type is
demoable on a separate node.
{% enddocs %}
