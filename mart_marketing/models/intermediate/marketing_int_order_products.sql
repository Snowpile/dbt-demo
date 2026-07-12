{{ config(materialized='table') }}

-- One row per line item enriched with product type (table; widest grain).
with items as (
    select * from {{ ref('marketing_stg_order_items') }}
),

products as (
    select * from {{ ref('marketing_stg_products') }}
)

select
    items.order_item_id,
    items.order_id,
    items.sku,
    products.product_type
from items
inner join products on items.sku = products.sku
