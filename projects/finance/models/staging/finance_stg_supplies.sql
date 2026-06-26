with source as (
    select * from {{ source('raw', 'raw_supplies') }}
),

renamed as (
    select
        id as supply_id,
        name as supply_name,
        {{ cents_to_dollars('cost') }} as cost_usd,
        perishable,
        sku
    from source
)

select * from renamed
