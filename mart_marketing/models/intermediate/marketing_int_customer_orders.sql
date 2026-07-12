with orders as (
    select * from {{ ref('marketing_stg_orders') }}
)

select
    customer_id,
    count(*) as order_count,
    sum(order_total_usd) as total_spend_usd,
    min(order_date) as first_order_date,
    max(order_date) as last_order_date
from orders
group by customer_id
