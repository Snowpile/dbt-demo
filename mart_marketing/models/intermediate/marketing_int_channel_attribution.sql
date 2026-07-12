-- Deterministically attribute each customer to one acquisition channel
-- by hashing the customer id across the channel reference seed.
with customers as (
    select
        customer_id,
        hash(customer_id) % (select count(*) from {{ ref('marketing_stg_channels') }}) as channel_idx
    from {{ ref('marketing_stg_customers') }}
),

channels as (
    select
        channel,
        channel_group,
        row_number() over (order by channel) - 1 as channel_idx
    from {{ ref('marketing_stg_channels') }}
)

select
    customers.customer_id,
    channels.channel,
    channels.channel_group
from customers
inner join channels on customers.channel_idx = channels.channel_idx
