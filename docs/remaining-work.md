# dbt_demo — Remaining Work (execution tracker)

*Working plan. Check items off as we go. The exhaustive feature reference stays in `docs/dbt-master-checklist.md`; this file is the prioritized "what's left + how" view.*

**Legend:** `[ ]` todo · `[~]` partial · `[x]` done · `[!]` blocked/decision needed

---

## Phase 0 — Housekeeping

- [x] Pre-commit + sqlfluff + dbt-checkpoint wired (`setup.sh`, `.pre-commit-config.yaml`; SQLFluff also runs in `pre-commit.yml` on changed model SQL)
- [x] `summary.md` → pointer to `docs/STATUS.md` + `docs/demo-agenda.md`
- [ ] Run `pre-commit run --all-files` (formatting churn) vs. later — optional

---

## Phase 0.5 — Demo readiness [~] in progress

Live script: **`docs/demo-agenda.md`**. Walkthrough checklist: **`DEMO_CHECKLIST.md`** (progress + **re-review** sections at top).

**Next week:** §3–§10 in checklist (§1 done; §2 N/A). Finish with timed dry run.

---

## Phase 1 — Model build-out ✅ DONE

All three domains meet the spec (≥3 stg / 7 int / 3 marts incl. incremental, seed, macro, custom test).
Verified green on dev/staging/prod via `./scripts/dbt_build_all.sh`.

---

## Phase 2 — dbt feature coverage (`mart_showcase/` + spread across domains)

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

### Model configs (one worked example each, `mart_showcase/`)
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
- [x] SQLFluff + pre-commit in CI — via `pre-commit.yml` (changed files); not a separate workflow step
- [ ] Slim CI + defer + manifest artifact upload from `main`
- [ ] Matrix build across 3 domain projects

---

## Acceptance criteria (definition of done)
- [x] Every project meets Phase 1 spec — verified
- [x] `dbt_build_all.sh` green on dev, staging, prod
- [x] Meeting script complete — `docs/demo-agenda.md`
- [ ] `docs/dbt-master-checklist.md` Status columns updated to reflect demo coverage
- [x] Repo on GitHub with CI defined (`.github/workflows/ci.yml`)
