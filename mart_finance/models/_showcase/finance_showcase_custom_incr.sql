{#
  Showcase: incremental_strategy=custom.

  Naming rule: strategy name X → macro get_incremental_X_sql(arg_dict).
  Here X=custom → macros/get_incremental_custom_sql.sql.

  Flow: dbt builds this SELECT into a temp table, then your macro returns the DML
  that writes temp → target (arg_dict has target_relation, temp_relation,
  unique_key, dest_columns, …). This demo just calls get_incremental_merge_sql —
  a real custom strategy would emit specialized DML instead.
#}
{{
    config(
        materialized='incremental',
        incremental_strategy='custom',
        unique_key='store_id',
        tags=['finance', 'showcase', 'custom_strategy_demo'],
        meta={'demo_features': ['custom_incremental_strategy']},
        group='finance_core',
        access='private'
    )
}}

select
    store_id,
    store_name,
    current_timestamp as custom_merged_at
from {{ ref('finance_stg_stores') }}
