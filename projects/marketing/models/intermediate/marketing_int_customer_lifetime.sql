with customer_orders as (
    select * from {{ ref('marketing_int_customer_orders') }}
),

bounds as (
    select max(order_date) as as_of_date from {{ ref('marketing_stg_orders') }}
)

select
    customer_orders.customer_id,
    customer_orders.order_count,
    customer_orders.total_spend_usd,
    round(customer_orders.total_spend_usd / customer_orders.order_count, 2) as avg_order_value_usd,
    customer_orders.first_order_date,
    customer_orders.last_order_date,
    date_diff('day', customer_orders.first_order_date, customer_orders.last_order_date) as lifespan_days,
    date_diff('day', customer_orders.last_order_date, bounds.as_of_date) as recency_days
from customer_orders
cross join bounds
