with orders as (
    select * from {{ ref('operations_stg_orders') }}
),

customers as (
    select * from {{ ref('operations_stg_customers') }}
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        customers.first_name,
        customers.last_name,
        orders.order_date,
        orders.order_status
    from orders
    left join customers on orders.customer_id = customers.customer_id
)

select * from final
