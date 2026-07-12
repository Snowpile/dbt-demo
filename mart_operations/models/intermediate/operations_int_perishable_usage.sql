with items as (
    select * from {{ ref('operations_stg_order_items') }}
),

orders as (
    select
        order_id,
        order_date
    from {{ ref('operations_stg_orders') }}
),

supplies as (
    select * from {{ ref('operations_stg_supplies') }}
)

select
    orders.order_date,
    sum(case when supplies.perishable then 1 else 0 end) as perishable_units,
    count(*) as total_units
from items
inner join supplies on items.sku = supplies.sku
inner join orders on items.order_id = orders.order_id
group by orders.order_date
