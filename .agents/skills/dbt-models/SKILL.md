---
name: dbt-models
description: >-
  dbt SQL/YAML conventions for mart_* projects on DuckDB. Use when editing
  models, schema.yml, sources, macros, tests, or running dbt in mart_finance,
  mart_marketing, mart_operations, or mart_combined.
---

# dbt (mart_* projects)

- Run from `mart_<domain>/` (each has its own `dbt_project.yml`). Exception: `mart_combined` is docs-only.
- Names: `{domain}_{layer}_{entity}` — `stg` / `int` / `fct` / `dim`.
- DuckDB targets: dev / staging / prod (see `profiles.yml.example`).
- PKs: `{entity}_id` — `unique` + `not_null` in `schema.yml`.
- After edits: `dbt parse`, `dbt compile --select <model>+`, `dbt test --select <model>+`.
- Shared field docs: `models/docs.md` + `{{ doc() }}`. Detail: `docs/conventions.md`.
