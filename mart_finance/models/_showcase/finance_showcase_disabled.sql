{#
  Showcase configs: enabled=false (stays in the project, skipped by dbt build/run).
  Intentionally not referenced by other models.
#}
{{ config(enabled=false, tags=['finance', 'showcase', 'disabled_demo']) }}

select
    cast(null as varchar) as never_built_id,
    current_timestamp as noted_at
