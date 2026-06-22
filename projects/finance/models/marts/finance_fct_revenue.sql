{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with payments as (
    select * from {{ ref('finance_stg_payments') }}
),

pivoted as (
    select
        order_id,
        {% for method in payment_methods %}
        sum(case when payment_method = '{{ method }}' then amount else 0 end) as {{ method }}_amount,
        {% endfor %}
        sum(amount) as total_amount
    from payments
    group by order_id
),

orders as (
    select * from {{ ref('finance_stg_orders') }}
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        {% for method in payment_methods %}
        coalesce(pivoted.{{ method }}_amount, 0) as {{ method }}_amount,
        {% endfor %}
        coalesce(pivoted.total_amount, 0) as total_amount
    from orders
    left join pivoted on orders.order_id = pivoted.order_id
)

select * from final
