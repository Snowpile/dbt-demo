with items as (
    select * from {{ ref('operations_stg_order_items') }}
),

supplies as (
    select * from {{ ref('operations_stg_supplies') }}
)

select
    items.order_id,
    count(*) as supplies_consumed,
    sum(case when supplies.perishable then 1 else 0 end) as perishable_consumed
from items
inner join supplies on items.sku = supplies.sku
group by items.order_id
