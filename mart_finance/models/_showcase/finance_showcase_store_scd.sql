{#
  Showcase: incremental_strategy=merge, unique_key, incremental_predicates,
  full_refresh=false, contract (YAML), group/access, indexes via post_hook.
#}
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='store_id',
        full_refresh=false,
        on_schema_change='fail',
        incremental_predicates=[
            "DBT_INTERNAL_DEST.opened_at >= date '2010-01-01'"
        ],
        tags=['finance', 'showcase', 'merge_demo'],
        meta={'demo_features': ['merge', 'incremental_predicates', 'contract', 'indexes']},
        group='finance_core',
        access='protected',
        post_hook=[
            "create index if not exists idx_finance_showcase_store_scd_store_id on {{ this }} (store_id)"
        ]
    )
}}

select
    store_id,
    store_name,
    opened_at,
    tax_rate,
    cast(current_timestamp as timestamp) as merged_at
from {{ ref('finance_stg_stores') }}
{% if is_incremental() %}
    where opened_at >= date '2010-01-01'
{% endif %}
