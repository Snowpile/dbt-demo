{#
  Showcase: microbatch (event_time, begin, batch_size, lookback).
  No unique_key — microbatch is time-window delete+insert per batch.
#}
{{
    config(
        materialized='incremental',
        incremental_strategy='microbatch',
        event_time='ordered_at',
        begin='2026-01-01',
        batch_size='month',
        lookback=0,
        concurrent_batches=false,
        tags=['finance', 'showcase', 'microbatch_demo'],
        meta={'demo_features': ['microbatch', 'event_time', 'batch_size', 'lookback']},
        group='finance_core',
        access='private'
    )
}}

select
    order_id,
    store_id,
    customer_id,
    ordered_at,
    order_total_usd
from {{ ref('finance_stg_orders') }}
