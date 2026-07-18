{#
  Custom incremental strategy: incremental_strategy='custom' looks up this macro
  by name (get_incremental_<strategy>_sql).

  arg_dict keys (typical): target_relation, temp_relation, unique_key,
  dest_columns, incremental_predicates. Return the full DML string.

  Demo: delegate to the adapter's merge. Replace the body with warehouse-specific
  SQL when you need behavior merge/append/delete+insert do not provide.
#}
{% macro get_incremental_custom_sql(arg_dict) %}
  {{ return(get_incremental_merge_sql(arg_dict)) }}
{% endmacro %}
