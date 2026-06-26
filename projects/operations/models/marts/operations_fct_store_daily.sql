with performance as (
    select * from {{ ref('operations_int_store_performance') }}
)

select
    md5(concat_ws('-', store_id, cast(order_date as varchar))) as store_day_id,
    store_id,
    store_name,
    order_date,
    order_count,
    item_count,
    revenue_usd,
    daily_order_target,
    target_attainment,
    met_target
from performance
