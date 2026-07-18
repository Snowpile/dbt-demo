{% docs finance_fct_order_revenue %}
Incremental order-grain revenue fact.

**Incremental strategy**

- `unique_key='order_id'`
- `incremental_strategy='delete+insert'`
- `on_schema_change='append_new_columns'`

**Incremental-of-incrementals**

On incremental runs this model filters to `order_id` values from
`finance_int_changed_order_ids`, which unions keys from two upstream incremental
models (`finance_int_orders_delta`, `finance_int_order_items_delta`). That keeps the
child join cheap when more than one parent can introduce work.

**Hooks**

`pre_hook` applies a retention `DELETE` and writes an audit row; `post_hook` stamps
`loaded_at` and writes another audit row (see `audit.dbt_model_hooks`).
{% enddocs %}
