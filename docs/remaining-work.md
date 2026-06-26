# benderik — Remaining Work (execution tracker)

*Working plan. Check items off as we go. The exhaustive feature reference stays in `docs/dbt-master-checklist.md`; this file is the prioritized "what's left + how" view.*

**Legend:** `[ ]` todo · `[~]` partial · `[x]` done · `[!]` blocked/decision needed

---

## Phase 0 — Housekeeping (fast, do first)

- [ ] Commit pre-commit + sqlfluff work (`.pre-commit-config.yaml`, `.sqlfluff`, `requirements.json`, `setup.sh`) — *only on your say-so*
- [ ] Refresh stale `summary.md` (dated 06-22; docs-serve + staging/prod now verified; pre-commit not mentioned)
- [!] Push to GitHub — resolve Snowpile vs Hoodie SSH account mismatch (fix steps in `summary.md`)
- [ ] Decide: run `pre-commit run --all-files` now (formatting churn) vs. later

---

## Phase 1 — Model build-out (the core spec) ✅ DONE

*Completed: richer `dbt-labs/jaffle-shop` star schema vendored (orders/items/products/supplies/stores/customers, ~62k orders). All three domains rebuilt and green on dev/staging/prod (finance 50 / marketing 52 / operations 46 nodes per target). Each project: ≥3 staging views, 7 intermediate (ephemeral+view+table), 3 marts (table + incremental), 1 seed, 1 macro (`cents_to_dollars`), 1 custom generic test (`not_negative`).*

**Per-project minimums (apply to `finance`, `marketing`, `operations`):**

| Layer | Min count | Required materializations |
|---|---|---|
| Stage / bronze | **3** | `view` |
| Transform / silver (intermediate) | **6–9** | mix of `ephemeral` + `view` + `table` |
| Mart / gold | **3** | ≥1 `table` **and** ≥1 `incremental` |

**Plus, each project must demonstrate:**
- [x] ≥1 **seed** (project-specific reference data) + a staging model over it
- [x] `view`, `table`, **and** `incremental` (+ `ephemeral`) materializations all present
- [x] ≥1 **macro** used in at least one model (`cents_to_dollars`)
- [x] ≥1 **custom generic test** applied to at least one column (`not_negative`)

### Current → target gap (identical across all 3 projects today)

| Layer | Now | Target | Add |
|---|---|---|---|
| Stage | 2 | 3+ | +1 (from new seed) |
| Intermediate | 1 | 6–9 | +5–8 |
| Mart | 2 | 3+ | +1 (make it incremental) |

### Per-project checklist (done ×3: finance / marketing / operations)

- [x] Project seed CSV in `projects/<domain>/seeds/` + loaded via `dbt build`
- [x] Staging `view` over the seed
- [x] Intermediate grown to 7, decomposed by concern, incl. `ephemeral` + materialized `table`
- [x] Incremental fct mart using `is_incremental()` + `unique_key` + `delete+insert` + `on_schema_change`
- [x] Shared macro (`cents_to_dollars`) used in staging models
- [x] Custom generic test (`not_negative`) applied to money/count columns
- [x] `unique` + `not_null` PK tests on every mart
- [x] `schema.yml` descriptions for all models/columns (+ `accepted_values` on categoricals)
- [x] `dbt_build_all.sh` green on dev, staging, prod

### [x] Decision — RESOLVED: Option B
Added the richer `dbt-labs/jaffle-shop` star schema (orders/items/products/supplies/stores/customers) for realistic joins, plus a small reference seed per domain.

---

## Phase 2 — dbt feature coverage (`projects/_showcase/` + spread across domains)

### Materializations & incremental (crucial)
- [ ] `view` — covered by stage/int *(verify after Phase 1)*
- [ ] `table` — covered by marts *(verify after Phase 1)*
- [ ] `incremental` — append, `delete+insert`, and `merge` strategies (≥1 per project in Phase 1; document all three)
- [ ] `ephemeral` — int-layer CTE replacement
- [ ] `incremental` configs: `unique_key`, `on_schema_change`, `incremental_predicates`, `full_refresh`
- [ ] microbatch (`event_time`, `batch_size`, `begin`/`end`, `lookback`) — if DuckDB supports
- [ ] `materialized view` — if DuckDB version supports

### Macros
- [ ] Project macro with args (`cents_to_dollars`)
- [ ] Surrogate-key style macro
- [ ] `is_incremental()` usage (ties to incremental marts)
- [ ] `run_query()` + `statement()` blocks
- [ ] `adapter.dispatch` cross-db macro
- [ ] Override `generate_schema_name` / `generate_alias_name`

### Tests
- [ ] **Custom generic test** macro (Phase 1 requirement) + extra examples
- [ ] Singular tests (`tests/*.sql`)
- [ ] Unit tests (`unit_tests:` given/expect)
- [ ] Source freshness (`loaded_at_field` + `freshness`)
- [ ] Broaden built-ins: `accepted_values`, `relationships`

### Seeds & resources
- [ ] Seeds (Phase 1 requirement) + document `dbt seed` vs `load_raw.py` patterns
- [ ] Snapshots (SCD2) + YAML snapshot config
- [ ] Analyses, exposures, metrics / semantic models

### Packages
- [ ] `packages.yml` + `dbt deps`
- [ ] `dbt_utils` (`star`, `union_relations`, `date_spine`)
- [ ] `dbt_expectations`, `audit_helper`, `codegen`

### Model configs (one worked example each, `projects/_showcase/`)
- [ ] Core: `enabled`, `alias`, `schema`, `tags`, `meta`, `group`, `access`
- [ ] Docs: `persist_docs`, `docs.node_color`
- [ ] Governance: `contract.enforced`, `grants`, `versions`
- [ ] Hooks: `pre-hook`, `post-hook`, `on-run-start`, `on-run-end`
- [ ] DuckDB-applicable perf: `indexes`, `+quote` (document `partition_by`/`cluster_by` as N/A)

### Selection, defer, state
- [ ] State selectors (`state:modified+`, `state:new`), `--defer --state`, `--favor-state`
- [ ] `dbt clone --state`
- [ ] `selectors.yml`, `dbt ls`, `dbt show`, `dbt retry`, `dbt run-operation`
- [ ] Selection examples in README (`tag:`, `path:`, `+model+`, `@source:`)

### Project-level config (`dbt_project.yml`)
- [ ] `vars`, behavior `flags`, `query-comment`, `dispatch`

---

## Phase 3 — Docs pipeline
- [ ] `dbt docs generate` per project + `{% docs %}` blocks (`models/docs.md`)
- [ ] `docs.show` on tests; richer column/model descriptions
- [ ] Deploy via GitHub Pages (`.github/workflows/docs.yml` → `gh-pages`) — *theoretical/no-run per repo rule*
- [ ] Combined multi-project vs per-domain docs sites

---

## Phase 4 — CI/CD (theoretical, never runs per repo rule)
- [ ] Slim CI + defer + manifest artifact upload from `main`
- [ ] Matrix build across 3 domain projects
- [ ] Add SQLFluff + pre-commit stages to CI workflow

---

## Acceptance criteria (definition of done)
- [ ] Every project meets the Phase 1 count + materialization + macro + custom-test + seed spec
- [ ] `dbt_build_all.sh` green on dev, staging, prod
- [ ] `docs/dbt-master-checklist.md` Status columns updated to reflect new coverage
- [ ] `summary.md` refreshed
- [ ] Repo pushed to correct GitHub account with CI defined
