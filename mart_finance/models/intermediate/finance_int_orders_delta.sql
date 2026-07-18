{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        tags=['finance', 'intermediate', 'incremental', 'delta']
    )
}}

-- Incremental parent #1 for the changed-order-id union pattern.
-- Accumulates order grain; each run only pulls rows newer than this table's watermark.

with orders as (
    select
        order_id,
        customer_id,
        store_id,
        ordered_at,
        order_date,
        subtotal_usd,
        tax_paid_usd,
        order_total_usd
    from {{ ref('finance_stg_orders') }}
)

select * from orders

{% if is_incremental() %}
    where ordered_at > (
        select coalesce(max(t.ordered_at), cast('1900-01-01' as timestamp))
        from {{ this }} as t
    )
{% endif %}
