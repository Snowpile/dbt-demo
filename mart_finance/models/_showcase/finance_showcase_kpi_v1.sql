{# Model version v1 — see _showcase.yml versions block. #}
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
    1 as kpi_version
from {{ ref('finance_stg_stores') }}
