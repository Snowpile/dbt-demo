with source as (
    select * from {{ ref('finance_margin_targets') }}
)

select
    product_type,
    target_margin_pct
from source
