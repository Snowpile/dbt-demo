{{ config(materialized='ephemeral') }}

-- Acquisition cohort per customer (ephemeral helper).
with orders as (
    select * from {{ ref('marketing_stg_orders') }}
)

select
    customer_id,
    min(order_date) as first_order_date,
    cast(date_trunc('month', min(order_date)) as date) as cohort_month
from orders
group by customer_id
