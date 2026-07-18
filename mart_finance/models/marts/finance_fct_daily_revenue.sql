{# post_hook demo lives here; pre_hook demo is on finance_fct_order_revenue. #}
{{
    config(
        tags=['finance', 'marts', 'post_hook_demo'],
        meta={'hooks': 'post_update_loaded_at_and_audit'},
        post_hook=[
            """
            update {{ this }}
            set loaded_at = current_timestamp
            where loaded_at is null
            """,
            """
            insert into audit.dbt_model_hooks (
                event_at, invocation_id, model_name, event_type, row_count, note
            )
            select
                current_timestamp,
                '{{ invocation_id }}',
                'finance_fct_daily_revenue',
                'post',
                count(*),
                'loaded_at stamped'
            from {{ this }}
            """
        ]
    )
}}

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
    end as gross_margin_pct,
    cast(null as timestamp) as loaded_at
from daily
left join stores on daily.store_id = stores.store_id
