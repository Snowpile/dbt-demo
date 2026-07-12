with enriched as (
    select * from {{ ref('operations_int_orders_enriched') }}
)

select
    store_id,
    store_name,
    order_date,
    count(*) as order_count,
    sum(item_count) as item_count,
    sum(order_total_usd) as revenue_usd
from enriched
group by store_id, store_name, order_date
