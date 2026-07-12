with source as (
    select * from {{ source('raw', 'raw_stores') }}
),

renamed as (
    select
        id as store_id,
        name as store_name,
        cast(opened_at as date) as opened_at,
        tax_rate
    from source
)

select * from renamed
