-- Architectural / one-off warehouse DDL (not part of the dbt DAG).
--
-- Run once per environment (or when adding new audit objects / roles), then leave
-- alone. Prefer this file over `on-run-start` / `on-run-end` in dbt_project.yml —
-- those hooks are fine for cold-start demos, but after init they can be removed.
--
-- Apply manually against the target DuckDB file (or your warehouse console), e.g.:
--   duckdb "$DUCKDB_PROD_PATH" < warehouse/ddl/architectural_ddl.sql
--
-- Add here: schemas, audit/log tables, grants, role setup, warehouse-native
-- objects that models assume already exist.

-- --- finance model-hook audit (used by pre_hook / post_hook demos) ---
create schema if not exists audit;

create table if not exists audit.dbt_model_hooks (
  event_at timestamp,
  invocation_id varchar,
  model_name varchar,
  event_type varchar,
  row_count bigint,
  note varchar
);

-- --- examples for real warehouses (document only on DuckDB) ---
-- grant usage on schema audit to role transformer;
-- grant select, insert on audit.dbt_model_hooks to role transformer;
-- grant select on all tables in schema mart to role analyst;
