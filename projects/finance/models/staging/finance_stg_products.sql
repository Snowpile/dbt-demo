with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        sku,
        name as product_name,
        type as product_type,
        {{ cents_to_dollars('price') }} as price_usd,
        description
    from source
)

select * from renamed
