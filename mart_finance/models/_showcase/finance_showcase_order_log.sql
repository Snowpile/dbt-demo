{#
  Showcase: incremental_strategy=append (event-style insert-only log).
#}
{{
    config(
        materialized='incremental',
        incremental_strategy='append',
        full_refresh=true,
        tags=['finance', 'showcase', 'append_demo'],
        meta={'demo_features': ['append', 'full_refresh']},
        group='finance_core',
        access='private'
    )
}}

select
    orders.order_id,
    orders.store_id,
    orders.ordered_at,
    current_timestamp as appended_at
from {{ ref('finance_stg_orders') }} as orders
{% if is_incremental() %}
    where orders.ordered_at > (
        select coalesce(max(existing.ordered_at), timestamp '1900-01-01')
        from {{ this }} as existing
    )
{% endif %}
