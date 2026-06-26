{{ config(materialized='table') }}

-- Materialized as a table: this is the widest fan-out (one row per line item).
with items as (
    select * from {{ ref('finance_stg_order_items') }}
),

margins as (
    select * from {{ ref('finance_int_product_margin') }}
)

select
    items.order_item_id,
    items.order_id,
    items.sku,
    margins.product_type,
    margins.price_usd,
    margins.unit_cost_usd,
    margins.unit_margin_usd
from items
inner join margins on items.sku = margins.sku
