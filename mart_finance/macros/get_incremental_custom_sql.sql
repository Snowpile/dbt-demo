{# Custom incremental strategy wrapper — demos the get_incremental_<name>_sql pattern. #}
{% macro get_incremental_custom_sql(arg_dict) %}
  {#- Specialize per warehouse via adapter.dispatch in real multi-adapter repos. -#}
  {{ return(get_incremental_delete_insert_sql(arg_dict)) }}
{% endmacro %}
