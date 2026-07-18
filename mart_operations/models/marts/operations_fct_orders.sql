{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

with enriched as (
    select * from {{ ref('operations_int_orders_enriched') }}
)

select
    order_id,
    customer_id,
    store_id,
    store_name,
    ordered_at,
    order_date,
    order_total_usd,
    item_count
from enriched

{% if is_incremental() %}
    where ordered_at > (select coalesce(max(t.ordered_at), cast('1900-01-01' as timestamp)) from {{ this }} as t)
{% endif %}
