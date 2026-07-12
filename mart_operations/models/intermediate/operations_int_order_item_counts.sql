{{ config(materialized='ephemeral') }}

-- Items per order (ephemeral helper).
with items as (
    select * from {{ ref('operations_stg_order_items') }}
)

select
    order_id,
    count(*) as item_count
from items
group by order_id
