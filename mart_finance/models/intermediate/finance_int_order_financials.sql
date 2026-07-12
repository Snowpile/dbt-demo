with orders as (
    select * from {{ ref('finance_stg_orders') }}
),

costs as (
    select * from {{ ref('finance_int_order_costs') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.store_id,
    orders.ordered_at,
    orders.order_date,
    orders.subtotal_usd,
    orders.tax_paid_usd,
    orders.order_total_usd,
    coalesce(costs.item_count, 0) as item_count,
    coalesce(costs.items_cost_usd, 0) as cogs_usd,
    orders.subtotal_usd - coalesce(costs.items_cost_usd, 0) as gross_profit_usd
from orders
left join costs on orders.order_id = costs.order_id
