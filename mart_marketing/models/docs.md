{#
  Shared column + model documentation for mart_marketing.
  Reuse via {{ doc('...') }} in schema.yml ONLY when semantics match.
  Same name, different meaning? → inline description in schema.yml
  (see docs/conventions.md → Documentation).

  Applicable models:
    order_id, customer_id, ordered_at → marketing_stg_orders, marketing_fct_customer_orders, …
    sku → marketing_stg_order_items, marketing_stg_products, …
    store_id, order_date → shared vocabulary (may appear as projects grow)
#}

{% docs order_id %}
Surrogate key for a single customer order. Stable across staging, intermediate, and mart
layers — reuse this doc block wherever `order_id` appears.
{% enddocs %}

{% docs customer_id %}
Identifier for the purchasing customer. Primary key on customer dimensions;
degenerate dimension on order facts.
{% enddocs %}

{% docs ordered_at %}
Timestamp when the order was placed (UTC). Used for incremental watermarks and
source freshness (`loaded_at_field` on `raw.raw_orders`).
{% enddocs %}

{% docs order_date %}
Calendar date of `ordered_at` (UTC). Prefer this for daily aggregations.
{% enddocs %}

{% docs sku %}
Stock-keeping unit / product code. Joins order line items to the product catalog.
{% enddocs %}

{% docs store_id %}
Store / location identifier.
{% enddocs %}

{% docs marketing_fct_customer_orders %}
Incremental order-grain fact for marketing (customer × order). Uses `delete+insert`
on `order_id`. Shared column descriptions live in this file (`{{ doc() }}` in schema.yml).
{% enddocs %}
