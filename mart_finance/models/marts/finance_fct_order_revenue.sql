{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns'
    )
}}

with financials as (
    select * from {{ ref('finance_int_order_financials') }}
)

select
    order_id,
    customer_id,
    store_id,
    ordered_at,
    order_date,
    subtotal_usd,
    tax_paid_usd,
    order_total_usd,
    item_count,
    cogs_usd,
    gross_profit_usd,
    case
        when subtotal_usd > 0 then round(gross_profit_usd / subtotal_usd, 4)
        else 0
    end as gross_margin_pct
from financials

{% if is_incremental() %}
    -- Only process orders newer than what we've already loaded.
    where ordered_at > (select coalesce(max(t.ordered_at), cast('1900-01-01' as timestamp)) from {{ this }} as t)
{% endif %}
