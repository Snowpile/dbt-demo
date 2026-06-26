with margins as (
    select * from {{ ref('finance_int_product_margin') }}
)

select
    sku as product_key,
    product_name,
    product_type,
    price_usd,
    unit_cost_usd,
    unit_margin_usd,
    margin_pct,
    target_margin_pct,
    below_target
from margins
