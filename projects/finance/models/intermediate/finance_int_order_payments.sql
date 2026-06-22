with payments as (
    select * from {{ ref('finance_stg_payments') }}
),

orders as (
    select * from {{ ref('finance_stg_orders') }}
),

order_payments as (
    select
        payments.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        sum(payments.amount) as total_amount,
        count(payments.payment_id) as payment_count
    from payments
    inner join orders on payments.order_id = orders.order_id
    group by 1, 2, 3, 4
)

select * from order_payments
