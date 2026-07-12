with orders as (
    select * from {{ ref('operations_stg_orders') }}
),

stores as (
    select * from {{ ref('operations_stg_stores') }}
),

item_counts as (
    select * from {{ ref('operations_int_order_item_counts') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.store_id,
    stores.store_name,
    orders.ordered_at,
    orders.order_date,
    orders.order_total_usd,
    coalesce(item_counts.item_count, 0) as item_count
from orders
left join stores on orders.store_id = stores.store_id
left join item_counts on orders.order_id = item_counts.order_id
