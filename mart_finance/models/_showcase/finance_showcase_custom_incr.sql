{# Showcase: incremental_strategy=custom → macros/get_incremental_custom_sql.sql #}
{{
    config(
        materialized='incremental',
        incremental_strategy='custom',
        unique_key='store_id',
        tags=['finance', 'showcase', 'custom_strategy_demo'],
        meta={'demo_features': ['custom_incremental_strategy']},
        group='finance_core',
        access='private'
    )
}}

select
    store_id,
    store_name,
    current_timestamp as custom_merged_at
from {{ ref('finance_stg_stores') }}
