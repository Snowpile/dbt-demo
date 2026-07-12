with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        id as order_id,
        customer as customer_id,
        cast(ordered_at as timestamp) as ordered_at,
        cast(ordered_at as date) as order_date,
        {{ cents_to_dollars('order_total') }} as order_total_usd
    from source
)

select * from renamed
