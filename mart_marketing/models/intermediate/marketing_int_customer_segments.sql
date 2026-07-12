with lifetime as (
    select * from {{ ref('marketing_int_customer_lifetime') }}
)

select
    customer_id,
    order_count,
    total_spend_usd,
    recency_days,
    case
        when order_count >= 3 and recency_days <= 30 then 'champion'
        when recency_days <= 30 then 'active'
        when recency_days <= 90 then 'at_risk'
        else 'dormant'
    end as segment
from lifetime
