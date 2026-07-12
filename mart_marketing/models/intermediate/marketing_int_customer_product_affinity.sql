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
    md5(concat_ws('-', orders.customer_id, order_products.product_type)) as affinity_id,
    orders.customer_id,
    order_products.product_type,
    count(*) as units
from order_products
inner join orders on order_products.order_id = orders.order_id
group by orders.customer_id, order_products.product_type
