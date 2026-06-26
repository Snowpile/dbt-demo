with stores as (
    select * from {{ ref('operations_stg_stores') }}
),

targets as (
    select * from {{ ref('operations_stg_store_targets') }}
),

bounds as (
    select max(order_date) as as_of_date from {{ ref('operations_stg_orders') }}
)

select
    stores.store_id,
    stores.store_name,
    stores.opened_at,
    stores.tax_rate,
    date_diff('day', stores.opened_at, bounds.as_of_date) as tenure_days,
    targets.daily_order_target
from stores
cross join bounds
left join targets on stores.store_name = targets.store_name
