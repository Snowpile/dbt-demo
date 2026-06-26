with costed as (
    select * from {{ ref('finance_int_order_items_costed') }}
)

select
    order_id,
    count(*) as item_count,
    sum(price_usd) as items_gross_usd,
    sum(unit_cost_usd) as items_cost_usd,
    sum(unit_margin_usd) as items_margin_usd
from costed
group by order_id
