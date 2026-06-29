# benderik — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update this at the end of every working session.**
Full backlog lives in `docs/remaining-work.md`; this file is the short, current snapshot + immediate next actions.*

**Last updated:** 2026-06-28

**Guardrail:** Only the human commits/pushes — the AI never runs `git commit`/`push`/`merge`/`rebase`/`reset` (see `.cursor/rules/core.mdc`).

---

## Snapshot

- **Branch:** `main` · **Tree:** clean (all work committed)
- **Last commit:** `f5b15cb` "Committing checkpoint" (Fri 2026-06-26)
- **Not yet pushed** to GitHub — blocked, see Open items.

## Recently done (last session)

- **pre-commit is green** on the default stage (`pre-commit run --all-files` passes). Fixes made:
  - `.sqlfluff`: added `load_macros_from_path` for the three `projects/*/macros` dirs so the jinja templater resolves `cents_to_dollars` (was causing TMP/PRS/LT02 cascade).
  - Qualified ambiguous `ordered_at` (RF02) in the incremental `where` of `finance_fct_order_revenue`, `marketing_fct_customer_orders`, `operations_fct_orders` (aliased the `{{ this }}` subquery as `t`).
  - `.pre-commit-config.yaml`: gated all dbt-checkpoint (manifest-based) hooks to `stages: [manual]` — they need a compiled `target/manifest.json` that doesn't exist on a local commit; shellcheck now ignores `SC1091`.
  - `.github/workflows/ci.yml`: runs the manual-stage dbt-checkpoint structural checks after `dbt_build_all.sh` (manifests exist there).
  - Added missing schema descriptions/tests: `finance_int_daily_revenue` (+desc, tests), `finance_stg_supplies`, `operations_int_store_performance`, `operations_stg_supplies`.

## Open items / next actions (priority order)

1. **[unverified]** The gated dbt-checkpoint checks were never confirmed locally — needs `setup.sh` (creates `.env` + `profiles.yml`) then build manifests and run:
   `for h in check-script-semicolon check-script-has-no-table-name check-model-has-description check-model-has-tests; do uv run pre-commit run "$h" --hook-stage manual --all-files; done`
   (Friday the shell had no `.env`/`profiles.yml`, so `dbt parse` failed with "Could not find profile named 'benderik'".)
2. **Push to GitHub** — blocked on Snowpile vs Hoodie SSH account mismatch (fix steps in `summary.md`).
3. **Refresh `summary.md`** — stale (dated 06-22; doesn't mention pre-commit / current state).
4. Continue Phase 2 dbt feature coverage — see `docs/remaining-work.md`.

## Resume quickly

```bash
./setup.sh                  # .env + .venv + profiles.yml + hooks
pre-commit run --all-files  # should be green
git status && git log --oneline -3
```

## Pointers

- Full prioritized backlog: `docs/remaining-work.md`
- Token-lean AI patterns: `docs/ai-practices-cursor.md`, `docs/ai-practices-claude.md`
- Exhaustive feature reference: `docs/dbt-master-checklist.md`
- GitHub/push notes: `docs/github.md`, `summary.md`
