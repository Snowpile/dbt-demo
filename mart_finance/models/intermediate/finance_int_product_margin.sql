with products as (
    select * from {{ ref('finance_stg_products') }}
),

costs as (
    select * from {{ ref('finance_int_product_cost') }}
),

targets as (
    select * from {{ ref('finance_stg_margin_targets') }}
),

joined as (
    select
        products.sku,
        products.product_name,
        products.product_type,
        products.price_usd,
        coalesce(costs.unit_cost_usd, 0) as unit_cost_usd,
        products.price_usd - coalesce(costs.unit_cost_usd, 0) as unit_margin_usd,
        case
            when products.price_usd > 0
                then round((products.price_usd - coalesce(costs.unit_cost_usd, 0)) / products.price_usd, 4)
            else 0
        end as margin_pct,
        targets.target_margin_pct
    from products
    left join costs on products.sku = costs.sku
    left join targets on products.product_type = targets.product_type
)

select
    *,
    margin_pct < target_margin_pct as below_target
from joined
