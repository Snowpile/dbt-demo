-- Singular test: no order may be dated in the future.
-- Returns the offending rows (i.e. fails) if any order_at is after "now".
select
    order_id,
    ordered_at
from {{ ref('finance_fct_order_revenue') }}
where ordered_at > current_timestamp
