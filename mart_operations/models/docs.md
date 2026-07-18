{#
  Shared column + model documentation for mart_operations.
  Reuse via {{ doc('...') }} in schema.yml ONLY when semantics match.
  Same name, different meaning? → inline description in schema.yml
  (see docs/conventions.md → Documentation).

  Applicable models:
    order_id, store_id, ordered_at → operations_stg_orders, operations_fct_orders, …
    sku → operations_stg_order_items, operations_stg_products, …
    customer_id, order_date → shared vocabulary
#}

{% docs order_id %}
Surrogate key for a single customer order. Stable across staging, intermediate, and mart
layers — reuse this doc block wherever `order_id` appears.
{% enddocs %}

{% docs customer_id %}
Identifier for the purchasing customer.
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

{% docs operations_fct_orders %}
Incremental order-grain operations fact. Uses `delete+insert` on `order_id`.
Shared column descriptions live in this file (`{{ doc() }}` in schema.yml).
{% enddocs %}
