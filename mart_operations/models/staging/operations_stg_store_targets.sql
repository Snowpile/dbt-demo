with source as (
    select * from {{ ref('operations_store_targets') }}
)

select
    store_name,
    daily_order_target
from source
