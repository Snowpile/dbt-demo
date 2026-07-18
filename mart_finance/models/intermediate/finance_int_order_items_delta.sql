{{
    config(
        materialized='incremental',
        unique_key='order_item_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        tags=['finance', 'intermediate', 'incremental', 'delta']
    )
}}

-- Incremental parent #2 for the changed-order-id union pattern.
-- Item grain; watermarked via parent order ordered_at so new/changed items flow in.

with items as (
    select
        i.order_item_id,
        i.order_id,
        i.sku,
        o.ordered_at
    from {{ ref('finance_stg_order_items') }} as i
    inner join {{ ref('finance_stg_orders') }} as o
        on i.order_id = o.order_id
)

select * from items

{% if is_incremental() %}
    where ordered_at > (
        select coalesce(max(t.ordered_at), cast('1900-01-01' as timestamp))
        from {{ this }} as t
    )
{% endif %}
