{{ config(severity='warn', store_failures=true) }}
-- Intentionally a WARN-level test (not an error): flags unusually high-margin
-- orders for analyst review without breaking the build. store_failures=true keeps
-- the offending rows in a table so you can query them after the run.
select
    order_id,
    gross_margin_pct
from {{ ref('finance_fct_order_revenue') }}
where gross_margin_pct > 0.8
