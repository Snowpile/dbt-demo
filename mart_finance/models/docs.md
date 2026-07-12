{% docs finance_fct_order_revenue__doc %}
Incremental order-grain revenue fact.

**How the incremental build works**

This model is materialized `incremental` with:

- `unique_key='order_id'` — identifies a row so re-loaded orders replace, not duplicate.
- `incremental_strategy='delete+insert'` — on each run dbt deletes the keys in the
  new batch, then inserts the new rows (atomic swap of the changed slice).
- `on_schema_change='append_new_columns'` — new columns added upstream are appended
  to the target rather than erroring.

On the **first run** (or `--full-refresh`) dbt builds the whole table. On
**subsequent runs** the `{% raw %}{% if is_incremental() %}{% endraw %}` block adds a
`where ordered_at > (select max(ordered_at) from {{ this }})` filter so only new
orders are processed. That keeps warehouse cost proportional to *new* data, not the
full history (~62k orders here).
{% enddocs %}

{% docs gross_margin_pct__doc %}
Gross profit divided by subtotal, rounded to 4 decimals. A ratio in the range
`[0, 1]` (guarded by the `accepted_range` custom generic test).
{% enddocs %}
