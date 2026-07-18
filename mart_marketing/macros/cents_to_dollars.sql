{# Money: integer cents → decimal dollars.
   adapter.dispatch when running under dbt; plain SQL when SQLFluff Jinja-lints. #}
{% macro cents_to_dollars(column_name, precision=2) -%}
    {%- if adapter is defined -%}
        {{ return(adapter.dispatch('cents_to_dollars', 'mart_marketing')(column_name, precision)) }}
    {%- else -%}
        round({{ column_name }} / 100.0, {{ precision }})
    {%- endif -%}
{%- endmacro %}

{% macro default__cents_to_dollars(column_name, precision=2) %}
    round({{ column_name }} / 100.0, {{ precision }})
{% endmacro %}
