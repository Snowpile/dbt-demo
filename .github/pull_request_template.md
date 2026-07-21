<!--
Title tips: Feature / Fix / Docs / Chore — one logical change.
Examples: "Feature: finance daily margin by store" · "Fix: Slim CI cold-start fallback" · "Docs: clarify defer sandbox"
-->

## Summary

<!-- What changed and why (1–3 bullets). Link issues if any: Closes #123 -->

-

## Motivation

<!-- Why now? Demo gap, bug, CI reliability, cleaner docs, etc. -->



## Scope

| Area | Touched? | Notes |
|------|----------|-------|
| `mart_finance` | ☐ | |
| `mart_marketing` | ☐ | |
| `mart_operations` | ☐ | |
| `mart_combined` (docs-only) | ☐ | |
| Seeds / `load_raw` | ☐ | |
| Scripts / `setup.sh` | ☐ | |
| CI / workflows (`.github/`) | ☐ | |
| Docs (`docs/`, `AGENTS.md`, README) | ☐ | |
| Orchestration stubs | ☐ | |

**Models / macros of note:** <!-- e.g. finance_fct_order_revenue, generate_schema_name -->

## To-do before merge

<!-- Delete this section if nothing applies -->

- [ ] Base branch is `main`
- [ ] Related PR / issue linked
- [ ] Post-merge: full refresh of incremental(s) — list: …
- [ ] Post-merge: re-publish `dbt-state` (only if changing how main publishes state)

## DAG / lineage

<!-- Optional but preferred for model PRs. Snap the changed subgraph from docs. -->

```bash
./dbt_docs.sh mart_finance          # :8011
# or: ./dbt_docs.sh mart_combined   # all-domain DAG :8010
```

<!-- Paste screenshot or describe nodes added/changed -->

## Validation

<!-- Prove the change does what you intend. Prefer paste/snippet over "trust me". -->

**Local (as applicable):**

```bash
. ./setup.sh
./scripts/load_raw.sh
cd mart_<domain>
dbt build --select <model>+
# Slim vs main (optional):
# ../scripts/slim_build.sh mart_<domain>
```

| Check | Result |
|-------|--------|
| `dbt build` / tests on selected nodes | ☐ pass |
| Ad-hoc SQL / row counts (`./scripts/sql.sh`) | ☐ n/a · ☐ done |
| Incremental: second run + optional `--full-refresh` | ☐ n/a · ☐ done |
| Defer / Slim locally if refs left unbuilt | ☐ n/a · ☐ done |

**CI:** PR should show pre-commit (changed files) + Slim CI (`state:modified+ --defer`). Note anything unexpected:

-

## Changes to existing models

<!-- Breaking changes, renamed columns, grain shifts, drop/recreate, BI follow-ups -->

- Breaking / contract change? ☐ no · ☐ yes — detail:
- Full refresh required after merge? ☐ no · ☐ yes — model(s):
- Downstream / exposure impact? ☐ no · ☐ yes —

## Checklist

### Shape of the PR

- [ ] One logical piece of work; commits are related and readable
- [ ] Naming follows `{domain}_{layer}_{entity}` (`docs/conventions.md`)
- [ ] New/changed mart PKs have `unique` + `not_null`
- [ ] New/changed models have a description (dbt-checkpoint); shared fields use `{{ doc() }}` when semantics match
- [ ] No raw table names in model SQL (`source()` / `ref()` only)
- [ ] SQLFluff / Ruff clean on touched files (or CI lint green)
- [ ] `vars.dev_schema` / defer sandbox still correct if schema macros changed
- [ ] Docs updated when behavior or demo path changes (`docs/`, README, agenda as needed)
- [ ] Seeds: if CSVs changed, checksums / `PROVENANCE.md` still accurate

### Skip / N/A

<!-- Check any that do not apply so reviewers know you considered them -->

- [ ] Docs-only / CI-only / chore — model checklist above mostly N/A
- [ ] Showcase / intentional WARN tests — called out in Summary
