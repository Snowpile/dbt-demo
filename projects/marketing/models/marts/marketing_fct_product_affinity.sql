with order_products as (
    select * from {{ ref('marketing_int_order_products') }}
),

orders as (
    select
        order_id,
        customer_id
    from {{ ref('marketing_stg_orders') }}
)

select
    order_products.product_type,
    count(*) as units_sold,
    count(distinct order_products.order_id) as order_count,
    count(distinct orders.customer_id) as customer_count
from order_products
inner join orders on order_products.order_id = orders.order_id
group by order_products.product_type
