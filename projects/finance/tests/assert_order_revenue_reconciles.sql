-- Singular test: the daily revenue roll-up must reconcile to order-grain revenue.
-- Returns rows (i.e. fails) only if the two marts disagree by more than a cent.
with daily as (
    select sum(revenue_usd) as total_usd
    from {{ ref('finance_fct_daily_revenue') }}
),

orders as (
    select sum(order_total_usd) as total_usd
    from {{ ref('finance_fct_order_revenue') }}
)

select
    daily.total_usd as daily_total_usd,
    orders.total_usd as order_total_usd
from daily
cross join orders
where abs(daily.total_usd - orders.total_usd) > 0.01
