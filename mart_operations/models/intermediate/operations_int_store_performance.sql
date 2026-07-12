with daily as (
    select * from {{ ref('operations_int_store_daily_orders') }}
),

targets as (
    select * from {{ ref('operations_stg_store_targets') }}
)

select
    daily.store_id,
    daily.store_name,
    daily.order_date,
    daily.order_count,
    daily.item_count,
    daily.revenue_usd,
    targets.daily_order_target,
    round(daily.order_count * 1.0 / nullif(targets.daily_order_target, 0), 3) as target_attainment,
    daily.order_count >= targets.daily_order_target as met_target
from daily
left join targets on daily.store_name = targets.store_name
