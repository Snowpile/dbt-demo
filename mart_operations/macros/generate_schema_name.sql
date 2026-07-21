{#-
    Prod + QA share one warehouse (prod.duckdb). Layer schemas are identical for both
    targets when dev_schema is unset.

    Resolution order:
      1. `--vars '{"dev_schema":"..."}'` -> one flat sandbox schema (defer / Slim CI /
         local branch work on prod data without clobbering prod marts).
      2. `prod` or `qa` target -> layer `+schema` verbatim (source_data, transform, mart).
-#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set dev_schema = var('dev_schema', '') -%}
    {%- if dev_schema | trim | length > 0 -%}
        {{ dev_schema | trim }}
    {%- elif target.name in ['prod', 'qa'] -%}
        {%- if custom_schema_name is none -%}
            {{ target.schema }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}
    {%- else -%}
        {{ exceptions.raise_compiler_error(
            "Unsupported target '" ~ target.name ~ "'. Use prod or qa (see docs/defer.md)."
        ) }}
    {%- endif -%}
{%- endmacro %}
