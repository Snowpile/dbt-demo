-- Analysis (not in the DAG): ad-hoc margin check compiled with `dbt compile`.
-- Run: dbt compile --select revenue_by_store_analysis
-- Then open target/compiled/.../analyses/revenue_by_store_analysis.sql

select
    store_id,
    store_name,
    order_date,
    revenue_usd,
    gross_margin_pct
from {{ ref('finance_fct_daily_revenue') }}
where gross_margin_pct < 0.2
order by order_date desc, revenue_usd desc
limit 50
