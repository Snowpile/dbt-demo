# benderik — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update this at the end of every working session.**
Full backlog lives in `docs/remaining-work.md`; this file is the short, current snapshot + immediate next actions.*

**Last updated:** 2026-06-29

**Guardrail:** Only the human commits/pushes — the AI never runs `git commit`/`push`/`merge`/`rebase`/`reset` (see `.cursor/rules/core.mdc`).

---

## Snapshot

- **Branch:** `main` · up to date with `origin/main` (push + the old Snowpile/Hoodie SSH issue are **resolved**).
- **Last commit:** `5303106` "Committing checkpoint; Lots of AI stuff".
- **Working tree:** has **uncommitted demo-readiness work** from the 2026-06-29 session (see log) — green and ready for the human to commit. Proposed message at the bottom.
- **Build:** green on dev — finance **61 PASS / 1 intentional WARN**, marketing **54**, operations **52**, 0 errors.

## Session log — 2026-06-29 (demo-readiness pass)

All items verified green via `./scripts/dbt_build_all.sh` + the manual dbt-checkpoint hooks.

- **Fixed a latent CI failure.** The gated `check-script-semicolon` / `check-script-has-no-table-name` hooks couldn't load a root `target/manifest.json` (repo is multi-project) and would have failed CI. Pinned both to `projects/finance/target/manifest.json` in `.pre-commit-config.yaml`. All four manual hooks now pass.
- **Custom generic tests (×3 projects):** added `not_empty_string` and parametrized `accepted_range(min_value, max_value, inclusive)` on top of `not_negative`.
- **`accepted_values`:** now in all three projects (added one to operations for parity).
- **Modernized all test args** to the dbt 1.10+ `arguments:` nesting — cleared a `MissingArgumentsPropertyInGenericTestDeprecation` that fired on fresh CI parses.
- **Singular tests (finance):** `assert_order_revenue_reconciles`, `assert_no_future_orders`.
- **`dbt_utils`** (1.4.1) via `packages.yml` + `dbt deps` in all three; real usage in finance via `dbt_utils.expression_is_true` and `dbt_utils.unique_combination_of_columns` tests.
- **`run-operation`** macro `audit_relations` (uses `run_query()`): `dbt run-operation audit_relations`.
- **Snapshot (SCD2):** `finance_snapshot_products` (YAML config, `check` strategy).
- **Source freshness:** on `raw_orders` (`loaded_at_field` + thresholds tuned for the static sample); `dbt source freshness` passes.
- **Unit test:** `test_stg_orders_cents_to_dollars` (given/expect).
- **Docs:** `{% docs %}` blocks in `projects/finance/models/docs.md` (incl. incremental explainer) referenced via `doc()`; `dbt docs generate` clean.
- **Extras:** warn-severity test `warn_high_margin_orders` (+`store_failures`), `store_failures` on a generic test, `revenue_dashboard` exposure, and a `dbt_project.yml` `vars` example (`revenue_start_date`) wired into `finance_stg_orders`.
- **New explainer doc:** `docs/dbt-feature-guide.md` (incremental models + `--defer --state` + demo command cheat-sheet).
- **Env-aware layered schemas (finance):** `generate_schema_name` override + per-layer `+schema` (`source_data` / `transform` / `mart`). prod/staging → bare names; dev → `dev_*` prefixed (un-tagged nodes → `dev`). `dev_schema` var flattens a `--defer` run into one sandbox schema. Fixed the `vars` demo command in the feature guide (`dbt run`, not `build`). All three projects still green.

## Session log — 2026-06-29 (review pass: cross-platform + demo agenda)

Reviewed a 5-item "what's missing" list. Items 1–3 (extra custom tests, `run-operation`,
`--defer --state` + `dev_schema` var) were already present and verified. Fixed the two real gaps:

- **Cross-platform (macOS + Windows).** `scripts/env.sh` hardcoded `.venv/bin/` — now detects
  `.venv/Scripts/` (Windows uv layout). `scripts/scan_downloads.sh` used `sha256sum` (absent on
  stock macOS) and bare `python3` (Windows Git Bash often `python`) — now falls back to
  `shasum -a 256` and auto-picks `python3`/`python`. Build chain now portable across Linux/macOS/Windows.
- **Demo agenda.** Added `docs/demo-agenda.md` — a sequential, timed step-by-step runbook
  (say/run per step) on top of the topic-organized `docs/dbt-feature-guide.md`.
- Re-verified: `./scripts/dbt_build_all.sh` green (finance/marketing/operations, 0 errors).
- **Dry-ran the demo agenda locally** (ls / run-operation / source freshness / snapshot all green).
  Caught + fixed a real bug in the `--defer --state` example: capturing state with `--target prod`
  fails on the DuckDB-per-file setup (`Binder Error: Catalog "prod" does not exist!` — the prod file
  isn't attached on the dev connection). Rewrote both `docs/demo-agenda.md` and `docs/dbt-feature-guide.md`
  to defer against the **dev** baseline + make a real edit so `state:modified+` selects something;
  added a DuckDB caveat note. Verified the corrected flow builds only the changed model + children (PASS, 0 err).

## Open items / next actions (priority order)

1. **Human: commit + push** the 2026-06-29 working tree (proposed message below), then confirm CI is green on GitHub.
2. **Spread breadth to marketing/operations** if desired — snapshot / freshness / unit test / exposure currently only demonstrated in finance (intentional, to keep the diff focused).
3. Continue Phase 2 depth as time allows — see `docs/remaining-work.md` (microbatch, more `dbt_utils`, snapshots in other domains, semantic models).

## Resume quickly

```bash
./setup.sh                                   # .env + .venv + profiles.yml + hooks (already present here)
source .venv/bin/activate && source scripts/env.sh
./scripts/dbt_build_all.sh                   # green: finance 61/1warn, marketing 54, operations 52
# manual structural hooks (need built manifests):
for h in check-script-semicolon check-script-has-no-table-name check-model-has-description check-model-has-tests; do
  uv run pre-commit run "$h" --hook-stage manual --all-files; done
```

## Proposed commit message (human runs it)

```
Add demo-readiness dbt coverage: tests, dbt_utils, snapshot, freshness, unit test, docs

- Fix gated dbt-checkpoint script hooks (manifest path) so CI passes
- Add not_empty_string + parametrized accepted_range generic tests across all 3 projects
- Modernize all test args to dbt 1.10+ arguments: syntax (clears deprecation)
- Add singular tests, dbt_utils package + tests, run-operation macro, SCD2 snapshot,
  source freshness, unit test, exposure, vars example, store_failures, {% docs %} blocks
- Add docs/dbt-feature-guide.md (incremental + --defer/--state explainers)
```

## Pointers

- Full prioritized backlog: `docs/remaining-work.md`
- Demo cheat-sheet / feature explainers: `docs/dbt-feature-guide.md`
- Token-lean AI patterns: `docs/ai-practices-cursor.md`, `docs/ai-practices-claude.md`
- Exhaustive feature reference: `docs/dbt-master-checklist.md`
- GitHub/push notes: `docs/github.md`, `summary.md`
