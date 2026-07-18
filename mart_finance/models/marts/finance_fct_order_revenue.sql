{# Model-level overrides: alias, tags, meta, pre_hook (post_hook is on finance_fct_daily_revenue). #}
{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        alias='fct_order_revenue',
        tags=['finance', 'marts', 'incremental', 'pre_hook_demo'],
        meta={'hooks': 'pre_delete_retention_and_audit'},
        pre_hook=[
            """
            insert into audit.dbt_model_hooks (
                event_at, invocation_id, model_name, event_type, row_count, note
            )
            values (
                current_timestamp,
                '{{ invocation_id }}',
                'finance_fct_order_revenue',
                'pre',
                null,
                'retention delete + audit'
            )
            """,
            """
            {% if is_incremental() %}
            delete from {{ this }}
            where ordered_at < (
                select coalesce(max(ordered_at), cast('1900-01-01' as timestamp))
                    - interval {{ var('order_retention_years') }} year
                from {{ this }}
            )
            {% else %}
            select 1
            {% endif %}
            """
        ]
    )
}}

-- Child incremental that depends on two incremental parents via the ID-union model.
-- Incremental runs only rebuild order_ids present in finance_int_changed_order_ids
-- that are newer than this table's watermark (avoids full history reprocessing).

with financials as (
    select * from {{ ref('finance_int_order_financials') }}
),

changed as (
    select
        order_id,
        ordered_at
    from {{ ref('finance_int_changed_order_ids') }}
)

select
    f.order_id,
    f.customer_id,
    f.store_id,
    f.ordered_at,
    f.order_date,
    f.subtotal_usd,
    f.tax_paid_usd,
    f.order_total_usd,
    f.item_count,
    f.cogs_usd,
    f.gross_profit_usd,
    case
        when f.subtotal_usd > 0 then round(f.gross_profit_usd / f.subtotal_usd, 4)
        else 0
    end as gross_margin_pct
from financials as f
{% if is_incremental() %}
    inner join changed as c
        on f.order_id = c.order_id
    where c.ordered_at > (
        select coalesce(max(t.ordered_at), cast('1900-01-01' as timestamp))
        from {{ this }} as t
    )
{% endif %}
