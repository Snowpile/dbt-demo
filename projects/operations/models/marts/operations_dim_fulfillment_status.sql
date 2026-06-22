with orders as (
    select * from {{ ref('operations_stg_orders') }}
),

final as (
    select
        order_status as fulfillment_status,
        count(order_id) as order_count,
        min(order_date) as first_seen_date,
        max(order_date) as last_seen_date
    from orders
    group by order_status
)

select * from final
