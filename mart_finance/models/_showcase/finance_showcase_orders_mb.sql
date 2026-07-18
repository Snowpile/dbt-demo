{#
  Showcase: incremental_strategy=microbatch.

  You do NOT write is_incremental() filters. dbt splits the run into time windows
  from event_time + batch_size, one query per batch (auto-filters upstream refs/
  sources that declare event_time). Each batch replaces that window in the target.

  begin     = earliest window on first / full-refresh run
  lookback  = reprocess N prior batches (late-arriving rows); 0 = only new windows
  concurrent_batches=false is required on file DuckDB (single-writer).

  Backfill: dbt run --select finance_showcase_orders_mb \
    --event-time-start '2026-01-01' --event-time-end '2026-03-01'
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
