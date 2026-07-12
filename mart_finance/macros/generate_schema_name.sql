{#-
    Env-aware schema naming + a `--defer` sandbox override.

    Resolution order:
      1. `--vars '{"dev_schema":"..."}'` set  -> build everything into that one flat
         schema (used with --defer so unbuilt refs still resolve to prod via state).
      2. Higher envs (prod / staging / qa)     -> the custom `+schema` verbatim
         (e.g. source_data, transform, mart), or the target's default schema when a
         node has no custom schema.
      3. Otherwise (dev)                        -> namespace everything under the env
         name: `dev` for un-tagged nodes, `dev_<custom>` for layered ones
         (dev_source_data ...), so a dev build can't clobber the prod schemas.
-#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set dev_schema = var('dev_schema', '') -%}
    {%- if dev_schema | trim | length > 0 -%}
        {{ dev_schema | trim }}
    {%- elif target.name in ['prod', 'staging', 'qa'] -%}
        {%- if custom_schema_name is none -%}
            {{ target.schema }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}
    {%- else -%}
        {%- if custom_schema_name is none -%}
            {{ target.name }}
        {%- else -%}
            {{ target.name }}_{{ custom_schema_name | trim }}
        {%- endif -%}
    {%- endif -%}
{%- endmacro %}
