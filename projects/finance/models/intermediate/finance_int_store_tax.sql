with orders as (
    select * from {{ ref('finance_stg_orders') }}
),

stores as (
    select * from {{ ref('finance_stg_stores') }}
)

select
    orders.order_id,
    orders.store_id,
    stores.store_name,
    stores.tax_rate,
    orders.subtotal_usd,
    orders.tax_paid_usd,
    round(orders.subtotal_usd * stores.tax_rate, 2) as expected_tax_usd,
    round(orders.tax_paid_usd - (orders.subtotal_usd * stores.tax_rate), 2) as tax_variance_usd
from orders
inner join stores on orders.store_id = stores.store_id
