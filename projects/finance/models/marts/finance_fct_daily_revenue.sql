with daily as (
    select * from {{ ref('finance_int_daily_revenue') }}
),

stores as (
    select * from {{ ref('finance_stg_stores') }}
)

select
    md5(concat_ws('-', daily.store_id, cast(daily.order_date as varchar))) as daily_revenue_id,
    daily.store_id,
    stores.store_name,
    daily.order_date,
    daily.order_count,
    daily.revenue_usd,
    daily.cogs_usd,
    daily.gross_profit_usd,
    case
        when daily.revenue_usd > 0 then round(daily.gross_profit_usd / daily.revenue_usd, 4)
        else 0
    end as gross_margin_pct
from daily
left join stores on daily.store_id = stores.store_id
