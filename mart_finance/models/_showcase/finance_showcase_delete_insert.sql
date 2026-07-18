{#
  Showcase: incremental_strategy=delete+insert.
  Prefer merge for upserts and append for insert-only logs; keep this model so
  every DuckDB strategy has a concrete example.
#}
{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        tags=['finance', 'showcase', 'delete_insert_demo'],
        meta={'demo_features': ['delete+insert']},
        group='finance_core',
        access='private'
    )
}}

select
    order_id,
    store_id,
    customer_id,
    ordered_at,
    order_total_usd,
    current_timestamp as refreshed_at
from {{ ref('finance_stg_orders') }}
{% if is_incremental() %}
    where ordered_at > (
        select coalesce(max(existing.ordered_at), timestamp '1900-01-01')
        from {{ this }} as existing
    )
{% endif %}
