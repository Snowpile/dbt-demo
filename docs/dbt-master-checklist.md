# dbt Master Feature Checklist — benderik

**Goal:** Make this repo the **#1 local, multi-domain reference** for dbt Core + DuckDB — covering everything Jaffle Shop *deliberately skips* and what advanced demos only touch in fragments.

**How to use:** Work top-to-bottom. Status: `✅` done · `🔶` partial · `⬜` not started · `🚫` N/A (DuckDB/scope).

**Current baseline:** 3 projects (`finance`, `marketing`, `operations`), stg→int→mart, generic tests, sources, CI `dbt build`. Most advanced features below are **⬜**.

---

## Your list (expanded)

| # | Feature | What “done” looks like in benderik | Status |
|---|---------|-----------------------------------|--------|
| 1 | **dbt docs — generate** | `dbt docs generate` per project; `persist_docs` example; doc blocks `{% docs %}` | ⬜ |
| 2 | **dbt docs — serve locally** | `scripts/docs_serve.sh`; documented port/host | ⬜ |
| 3 | **dbt docs — deploy** | GitHub Pages from `target/` artifacts **or** object-store static hosting **or** CI artifact + README | ⬜ |
| 4 | **Macros** | Project macros + package macros; documented call sites | ⬜ |
| 5 | **Tests — generic (built-in)** | `unique`, `not_null`, `accepted_values`, `relationships` across domains | 🔶 |
| 6 | **Tests — singular** | `.sql` tests in `tests/` | ⬜ |
| 7 | **Tests — custom generic** | reusable `test` macro in `macros/` | ⬜ |
| 8 | **Tests — unit tests** | YAML `unit_tests:` with `given`/`expect`, macro overrides | ⬜ |
| 9 | **Tests — freshness** | `loaded_at_field` + `freshness` on sources | ⬜ |
| 10 | **dbt defer** | `state/` artifact dir; `dbt build --select state:modified+ --defer --state state/` | ⬜ |
| 11 | **State selectors** | `state:modified`, `state:new`, `state:old`, `+state:modified+` in CI slim build | ⬜ |
| 12 | **dbt clone** | `dbt clone --state state/` example for zero-copy dev tables | ⬜ |
| 13 | **ALL model configs** | See § Model configs below — one worked example each | ⬜ |

---

## vs. other repos (why benderik should win)

| Repo | What it teaches | What it **skips** (benderik opportunity) |
|------|-----------------|------------------------------------------|
| [jaffle_shop_duckdb](https://github.com/dbt-labs/jaffle_shop_duckdb) | basics, seeds-as-raw anti-pattern | macros, packages, hooks, defer, incremental, snapshots, unit tests |
| [jaffle-shop](https://github.com/dbt-labs/jaffle-shop) | dbt Cloud, jafgen scale | advanced Core patterns, multi-project |
| [dbt-learn-demo](https://github.com/dbt-labs/dbt-learn-demo) | best practices naming | exhaustive config catalog |
| Community “advanced” blogs | one feature deep | single repo with **all** features cross-linked |

**benderik edge:** multi-domain monorepo + DuckDB (free/local) + **feature matrix with runnable examples** + AI agent docs.

---

## Commands (every CLI entry point)

| Command | Demonstrate in benderik | Status |
|---------|-------------------------|--------|
| `dbt build` | `scripts/dbt_build_all.sh` | ✅ |
| `dbt run` | documented per-domain | 🔶 |
| `dbt test` | in build | ✅ |
| `dbt seed` | optional vs `load_raw.py` (document both patterns) | 🔶 |
| `dbt snapshot` | SCD2 example model | ⬜ |
| `dbt compile` | in dev workflow | 🔶 |
| `dbt parse` | CI | ✅ |
| `dbt deps` | after `packages.yml` | ⬜ |
| `dbt docs generate` / `dbt docs serve` | docs pipeline | ⬜ |
| `dbt list` | selection examples in README | ⬜ |
| `dbt show` | preview model SQL output | ⬜ |
| `dbt debug` | onboarding troubleshooting | ⬜ |
| `dbt clean` | clean-targets | 🔶 |
| `dbt run-operation` | grant/ops macro | ⬜ |
| `dbt retry` | failed node retry demo | ⬜ |
| `dbt clone` | defer companion | ⬜ |
| `dbt source freshness` | stale source alert | ⬜ |

---

## Model materializations

| Materialization | Example model | Status |
|-----------------|---------------|--------|
| `view` | all `*_stg_*`, `*_int_*` | ✅ |
| `table` | all `*_fct_*`, `*_dim_*` | ✅ |
| `incremental` | append + merge examples | ⬜ |
| `incremental` + `microbatch` | time-partitioned fact | ⬜ |
| `ephemeral` | int layer CTE replacement | ⬜ |
| `materialized view` | if DuckDB version supports | ⬜ |

### Incremental strategies (document DuckDB support)

| Strategy | Example | Status |
|----------|---------|--------|
| `append` | event log | ⬜ |
| `delete+insert` | daily partition replace | ⬜ |
| `merge` | upsert with `unique_key` | ⬜ |
| `insert_overwrite` | 🚫 BQ-centric — document N/A | 🚫 |
| Custom strategy macro | wrapper pattern | ⬜ |

---

## Model configs — literally everything

*One minimal model per config in `projects/_showcase/` (recommended) or spread across domains.*

### Core

| Config | Example use | Status |
|--------|-------------|--------|
| `enabled: false` | disabled model in DAG | ⬜ |
| `alias` | override table name | ⬜ |
| `schema` | custom schema override | ⬜ |
| `database` | cross-db (if supported) | ⬜ |
| `tags` | `tag:finance`, CI selection | ⬜ |
| `meta` | owner, PII flags for docs | ⬜ |
| `group` | dbt mesh grouping | ⬜ |
| `access` | `protected` / `public` (mesh) | ⬜ |

### Materialization & incremental

| Config | Example | Status |
|--------|---------|--------|
| `materialized` | view/table/incremental/ephemeral | 🔶 |
| `incremental_strategy` | merge vs append | ⬜ |
| `unique_key` | incremental merge key | ⬜ |
| `on_schema_change` | append_new_columns / fail / sync | ⬜ |
| `full_refresh` | force full-refresh on model | ⬜ |
| `incremental_predicates` | filter incremental window | ⬜ |
| `event_time` | microbatch | ⬜ |
| `batch_size` | microbatch | ⬜ |
| `begin` / `end` | microbatch bounds | ⬜ |
| `lookback` | microbatch | ⬜ |

### Docs & presentation

| Config | Example | Status |
|--------|-------------|--------|
| `persist_docs` (relation + columns) | docs in warehouse comments | ⬜ |
| `docs.node_color` | DAG color in docs site | ⬜ |

### Hooks

| Config | Example | Status |
|--------|---------|--------|
| `pre-hook` | `log model start` | ⬜ |
| `post-hook` | `grant select`, analyze | ⬜ |
| `dbt_project.yml` `on-run-start` | audit log table | ⬜ |
| `dbt_project.yml` `on-run-end` | run summary insert | ⬜ |

### Governance

| Config | Example | Status |
|--------|---------|--------|
| `contract.enforced` | column name/type contract | ⬜ |
| `grants` | select to role (adapter-specific) | ⬜ |
| `versions` | model versioning pattern | ⬜ |

### Performance / adapter-specific

| Config | DuckDB? | Status |
|--------|---------|--------|
| `indexes` | limited | ⬜ |
| `partition_by` / `cluster_by` | 🚫 warehouse-specific — doc only | 🚫 |
| `+quote` | case-sensitive identifiers | ⬜ |

---

## Macros

| Type | Example | Status |
|------|---------|--------|
| Project macro | `cents_to_dollars` | ⬜ |
| Jinja macro with args | `generate_surrogate_key` style | ⬜ |
| `is_incremental()` usage | incremental model | ⬜ |
| `run_query()` | operations macro | ⬜ |
| `statement()` blocks | hooks/ops | ⬜ |
| `adapter.dispatch` | cross-db macro | ⬜ |
| Override `generate_schema_name` | env-based schemas | ⬜ |
| Override `generate_alias_name` | custom naming | ⬜ |
| Package macro (`dbt_utils`) | `star`, `union_relations`, `date_spine` | ⬜ |

---

## Packages

| Package | Features to demo | Status |
|---------|------------------|--------|
| `dbt-labs/dbt_utils` | generic tests, macros, date spine | ⬜ |
| `metaplane/dbt_expectations` | advanced data tests | ⬜ |
| `dbt-labs/audit_helper` | compare relations | ⬜ |
| `dbt-labs/codegen` | boilerplate generation | ⬜ |
| Private package pattern | documented, optional | ⬜ |

---

## Resources beyond models

| Resource | Example | Status |
|----------|---------|--------|
| **Sources** | `sources.yml` + `source()` | ✅ |
| **Seeds** | `dbt seed` vs `load_raw.py` (idiomatic raw) | 🔶 |
| **Snapshots** | SCD2 on customer status | ⬜ |
| **Snapshots in YAML** | declarative snapshot config | ⬜ |
| **Analyses** | ad-hoc SQL not in DAG | ⬜ |
| **Exposures** | downstream dashboard link | ⬜ |
| **Metrics** (legacy) | simple metric | ⬜ |
| **Semantic models / metrics** (MetricFlow) | if dbt version supports | ⬜ |
| **Groups** | mesh ownership | ⬜ |
| **Functions** (UDFs) | if adapter supports | ⬜ |

---

## Selection & graph

| Feature | Example command | Status |
|---------|-----------------|--------|
| `--select model` | single model | 🔶 |
| `--select tag:` | by tag | ⬜ |
| `--select path:` | by folder | ⬜ |
| `--select +model+` | lineage | ⬜ |
| `@source:name` | source selection | ⬜ |
| `dbt ls` / `dbt list` | list nodes | ⬜ |
| **YAML selectors** | `selectors.yml` named selectors | ⬜ |
| **State:** `state:modified+` | slim CI | ⬜ |
| **Defer** | `--defer --state` | ⬜ |
| **Favor state** | `--favor-state` | ⬜ |
| **Indirect selection** | `dbt build` test parents | 🔶 |

---

## Artifacts & defer workflow (end-to-end)

| Step | Implementation | Status |
|------|----------------|--------|
| Prod/staging generates `manifest.json` | CI uploads artifact | ⬜ |
| Dev stores `state/manifest.json` | `scripts/pull_state.sh` | ⬜ |
| Slim CI `state:modified+ --defer` | `.github/workflows/slim-ci.yml` | ⬜ |
| Document `DBT_STATE` / `DBT_DEFER_STATE` env vars | `docs/defer.md` | ⬜ |

---

## Documentation (full pipeline)

| Step | Command / file | Status |
|------|----------------|--------|
| Column + model descriptions | `schema.yml` | 🔶 |
| `{% docs %}` blocks | `models/docs.md` | ⬜ |
| `docs.show: true` on tests | in YAML | ⬜ |
| `dbt docs generate` | per project script | ⬜ |
| `dbt docs serve` | local | ⬜ |
| **Deploy — GitHub Pages** | `.github/workflows/docs.yml` → `gh-pages` branch | ⬜ |
| **Deploy — static S3/R2** | optional doc | ⬜ |
| Combined multi-project docs | union or per-domain sites | ⬜ |

---

## Project-level config (`dbt_project.yml`)

| Feature | Example | Status |
|---------|---------|--------|
| `name`, `version`, `profile`, `config-version` | all projects | ✅ |
| `model-paths`, `seed-paths`, etc. | all projects | ✅ |
| `vars` | project variables in SQL | ⬜ |
| `flags` / behavior flags | `require_batched_execution_*` | ⬜ |
| `query-comment` | audit trail | ⬜ |
| `dispatch` | package macro search order | ⬜ |
| `restrict-access` | mesh | ⬜ |
| Hierarchical `models:` config | staging/marts materializations | ✅ |

---

## Profiles & environments

| Feature | Status |
|---------|--------|
| Multi-target (`dev` / `staging` / `prod`) | ✅ |
| `DBT_PROFILES_DIR` pattern | ✅ |
| Env vars in profiles (`env_var`) | ✅ |
| `target-path`, `log-path`, `packages-install-path` | 🔶 |
| `threads`, `keepalives_idle`, etc. | ⬜ |

---

## CI/CD patterns (GitHub Actions)

| Pattern | Status |
|---------|--------|
| Full `dbt build` on PR | ✅ |
| `dbt parse` only (fast) | ✅ |
| Slim CI + defer | ⬜ |
| Upload `manifest` artifact from `main` | ⬜ |
| Matrix: 3 domain projects | ⬜ |
| SQL lint (SQLFluff) | ⬜ |
| pre-commit hooks | ⬜ |

---

## Developer experience

| Tool | Status |
|------|--------|
| `uv` + `requirements.json` | ✅ |
| `.sqlfluff` + dbt templater | ⬜ |
| `pre-commit-config.yaml` | ⬜ |
| VS Code / Cursor dbt extension notes | ⬜ |
| `dbt-jsonschema` YAML autocomplete | ⬜ |

---

## DuckDB-specific notes

| Topic | Status |
|-------|--------|
| File-per-env DuckDB paths | ✅ |
| `read_csv_auto` load pattern | ✅ |
| Incremental on DuckDB adapter | ⬜ verify & document |
| Grants / contracts support level | ⬜ document limits |

---

## Suggested implementation order (when we work the list)

1. `projects/_showcase/` — one model per config (single catalog)
2. `dbt_utils` package + macro examples
3. Docs generate + GitHub Pages deploy
4. Snapshots + incremental mart
5. Unit tests + singular tests + `dbt_expectations`
6. Defer/slim CI with manifest artifacts
7. Hooks, operations, exposures, analyses
8. Semantic layer (if version supports on DuckDB)

---

## Tracking

Update the **Status** column as we implement. Target: **≥95% ✅** for DuckDB-applicable rows; 🚫 only for truly warehouse-specific configs (with docs explaining why).

*Last updated: 2026-06-22*
