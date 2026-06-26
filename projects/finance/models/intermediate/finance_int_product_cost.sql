{{ config(materialized='ephemeral') }}

-- Bill-of-materials roll-up: unit cost per product (sum of its supplies).
with supplies as (
    select * from {{ ref('finance_stg_supplies') }}
)

select
    sku,
    sum(cost_usd) as unit_cost_usd,
    count(*) as supply_count,
    bool_or(perishable) as has_perishable_supply
from supplies
group by sku
