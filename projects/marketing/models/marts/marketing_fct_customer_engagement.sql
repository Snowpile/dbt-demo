with orders as (
    select * from {{ ref('marketing_stg_orders') }}
),

final as (
    select
        customer_id,
        count(order_id) as total_orders,
        count(distinct order_date) as active_order_days,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from orders
    group by customer_id
)

select * from final
