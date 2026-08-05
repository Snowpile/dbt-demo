{#
  Showcase: quoted identifier column (YAML quote: true).
  RF05 noqa: spaces in the alias are intentional for the quote demo.
#}
{{
    config(
        materialized='view',
        tags=['finance', 'showcase', 'quote_demo']
    )
}}

select
    store_id,
    store_name as "Store Name",  -- noqa: RF05
    tax_rate
from {{ ref('finance_stg_stores') }}
