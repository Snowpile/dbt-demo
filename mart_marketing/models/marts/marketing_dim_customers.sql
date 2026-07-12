with customers as (
    select * from {{ ref('marketing_stg_customers') }}
),

lifetime as (
    select * from {{ ref('marketing_int_customer_lifetime') }}
),

first_order as (
    select * from {{ ref('marketing_int_customer_first_order') }}
),

segments as (
    select * from {{ ref('marketing_int_customer_segments') }}
),

channels as (
    select * from {{ ref('marketing_int_channel_attribution') }}
),

favorite as (
    select
        customer_id,
        product_type as favorite_product_type
    from (
        select
            customer_id,
            product_type,
            row_number() over (partition by customer_id order by units desc, product_type asc) as rn
        from {{ ref('marketing_int_customer_product_affinity') }}
    ) as ranked
    where rn = 1
)

select
    customers.customer_id,
    customers.customer_name,
    coalesce(lifetime.order_count, 0) as order_count,
    coalesce(lifetime.total_spend_usd, 0) as total_spend_usd,
    lifetime.avg_order_value_usd,
    lifetime.first_order_date,
    lifetime.last_order_date,
    lifetime.recency_days,
    first_order.cohort_month,
    coalesce(segments.segment, 'no_orders') as segment,
    channels.channel,
    channels.channel_group,
    favorite.favorite_product_type
from customers
left join lifetime on customers.customer_id = lifetime.customer_id
left join first_order on customers.customer_id = first_order.customer_id
left join segments on customers.customer_id = segments.customer_id
left join channels on customers.customer_id = channels.customer_id
left join favorite on customers.customer_id = favorite.customer_id
