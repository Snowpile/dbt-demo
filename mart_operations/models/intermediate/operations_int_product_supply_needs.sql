{{ config(materialized='table') }}

-- Supply requirements per product (table).
with products as (
    select * from {{ ref('operations_stg_products') }}
),

supplies as (
    select * from {{ ref('operations_stg_supplies') }}
)

select
    products.sku,
    products.product_name,
    products.product_type,
    count(supplies.supply_id) as supply_count,
    sum(case when supplies.perishable then 1 else 0 end) as perishable_supply_count,
    sum(supplies.cost_usd) as total_supply_cost_usd
from products
left join supplies on products.sku = supplies.sku
group by products.sku, products.product_name, products.product_type
