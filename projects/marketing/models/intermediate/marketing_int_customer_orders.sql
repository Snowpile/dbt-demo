with customers as (
    select * from {{ ref('marketing_stg_customers') }}
),

orders as (
    select * from {{ ref('marketing_stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as order_count
    from orders
    group by customer_id
),

final as (
    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.order_count, 0) as order_count
    from customers
    left join customer_orders on customers.customer_id = customer_orders.customer_id
)

select * from final
