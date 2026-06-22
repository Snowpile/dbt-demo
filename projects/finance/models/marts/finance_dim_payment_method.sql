with payments as (
    select * from {{ ref('finance_stg_payments') }}
),

final as (
    select
        payment_method as payment_method_code,
        sum(amount) as total_collected_amount,
        count(payment_id) as payment_count,
        count(distinct order_id) as order_count
    from payments
    group by payment_method
)

select * from final
