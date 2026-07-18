{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        tags=['finance', 'intermediate', 'incremental', 'changed_ids']
    )
}}

-- Unions order_ids that need reprocessing from BOTH incremental parents.
-- Downstream incrementals (e.g. finance_fct_order_revenue) filter to this key set
-- so the child does not re-scan wide joins just to discover what changed.

with from_orders as (
    select
        order_id,
        ordered_at
    from {{ ref('finance_int_orders_delta') }}
),

from_items as (
    select
        order_id,
        max(ordered_at) as ordered_at
    from {{ ref('finance_int_order_items_delta') }}
    group by order_id
),

unioned as (
    select
        order_id,
        ordered_at
    from from_orders
    union all
    select
        order_id,
        ordered_at
    from from_items
)

select
    order_id,
    max(ordered_at) as ordered_at
from unioned
group by order_id

{% if is_incremental() %}
    having max(ordered_at) > (
        select coalesce(max(t.ordered_at), cast('1900-01-01' as timestamp))
        from {{ this }} as t
    )
{% endif %}
