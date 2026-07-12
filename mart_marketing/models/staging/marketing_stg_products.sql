with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        sku,
        name as product_name,
        type as product_type
    from source
)

select * from renamed
