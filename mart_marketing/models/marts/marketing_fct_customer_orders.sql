{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns'
    )
}}

with orders as (
    select * from {{ ref('marketing_stg_orders') }}
),

item_counts as (
    select
        order_id,
        count(*) as item_count
    from {{ ref('marketing_stg_order_items') }}
    group by order_id
)

select
    orders.order_id,
    orders.customer_id,
    orders.ordered_at,
    orders.order_date,
    orders.order_total_usd,
    coalesce(item_counts.item_count, 0) as item_count
from orders
left join item_counts on orders.order_id = item_counts.order_id

{% if is_incremental() %}
    where orders.ordered_at > (select coalesce(max(t.ordered_at), cast('1900-01-01' as timestamp)) from {{ this }} as t)
{% endif %}
