with financials as (
    select * from {{ ref('finance_int_order_financials') }}
)

select
    store_id,
    order_date,
    count(*) as order_count,
    sum(order_total_usd) as revenue_usd,
    sum(cogs_usd) as cogs_usd,
    sum(gross_profit_usd) as gross_profit_usd
from financials
group by store_id, order_date
