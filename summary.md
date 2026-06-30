# benderik — session summary

*Last updated: 2026-06-29. Read this to pick up where we left off.*

## What this repo is

AI-friendly data engineering sandbox: **3 dbt projects** on **DuckDB**, sharing the richer **dbt-labs/jaffle-shop** star schema. Domains: `finance`, `marketing`, `operations`.

## Done ✓

| Area | Status |
|------|--------|
| AI config | `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/` |
| Sample data | jaffle-shop star schema (customers/orders/items/products/supplies/stores), ~62k orders, SHA-256 pinned + scanned |
| dbt models | per domain: ≥3 stg (view) / 7 int (ephemeral+view+table) / 3 marts (table + **incremental**); **green on dev/staging/prod** |
| dbt tests | `not_negative`, `not_empty_string`, parametrized `accepted_range` custom generic tests (×3); `accepted_values` (×3); singular + unit tests; `dbt_utils` tests; warn-severity + `store_failures` (finance) |
| dbt features | per-domain seed, `cents_to_dollars` macro, `audit_relations` run-operation, SCD2 snapshot, source freshness, `vars`, exposure, `{% docs %}` blocks (finance) |
| Packages | `dbt_utils` 1.4.1 via `packages.yml` + `dbt deps` (×3) |
| Tooling | `uv` + `requirements.json` (`./setup.sh`), `scripts/dbt_build_all.sh`, pre-commit + sqlfluff + dbt-checkpoint |
| CI | `.github/workflows/ci.yml` — build + manual structural hooks (script-hook manifest path **fixed** 06-29) |
| **git** | on `main`, **pushed**, up to date with `origin/main` |

## Where we're at

- **Local dbt:** `./scripts/dbt_build_all.sh` is green — finance **61 PASS / 1 intentional WARN**, marketing **54**, operations **52**.
- **Model build-out (Phase 1):** ✅ complete. **Phase 0.5 demo-readiness:** ✅ complete (see `docs/remaining-work.md`).
- **Uncommitted:** the 2026-06-29 demo-readiness work (tests, `dbt_utils`, snapshot, freshness, unit test, docs, exposure, vars, CI hook fix) — green, ready for the human to commit. See `docs/STATUS.md` for the proposed commit message.
- **GitHub push:** ✅ done — `origin` is `git@github-snowpile:Snowpile/benderik.git`, branch up to date. (The old Snowpile/Hoodie SSH mismatch is resolved.)

## Quick start

```bash
cd ~/Desktop/Contracting/benderik
./setup.sh
source .venv/bin/activate && source scripts/env.sh
./scripts/dbt_build_all.sh
```

## Demo feature cheat-sheet

See `docs/dbt-feature-guide.md` for runnable commands + explainers (incremental models, `--defer --state`, run-operation, snapshot, freshness, unit/singular tests, store_failures, vars, docs).

## Still to do

See `docs/remaining-work.md` for the full prioritized tracker. Headlines:
1. Human: commit + push the 06-29 working tree; confirm CI green on GitHub.
2. Optionally spread snapshot/freshness/unit-test/exposure to marketing + operations (currently finance-only, kept focused).
3. Phase 2+ depth: more incremental strategies (merge/append/microbatch), more `dbt_utils` (`star`/`date_spine`), semantic models, GitHub Pages docs, Slim CI + defer.

## Key files

| File | Purpose |
|------|---------|
| `AGENTS.md` | AI rules + commands |
| `docs/github.md` | PR workflow (update for Snowpile remote) |
| `projects/README.md` | Domain model map |
| `docs/dbt-master-checklist.md` | **Full dbt feature matrix** — implement later |

## For AI

Say: *“Read `summary.md` and continue.”* Do not commit unless asked.
