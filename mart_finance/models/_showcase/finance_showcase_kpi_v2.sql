{# Model version v2 — adds tax_rate; latest_version in _showcase.yml. #}
{{
    config(
        materialized='view',
        tags=['finance', 'showcase', 'versions_demo'],
        group='finance_core',
        access='public'
    )
}}

select
    store_id,
    store_name,
    tax_rate,
    2 as kpi_version
from {{ ref('finance_stg_stores') }}
