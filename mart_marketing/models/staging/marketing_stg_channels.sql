with source as (
    select * from {{ ref('marketing_channels') }}
)

select
    channel,
    channel_group
from source
