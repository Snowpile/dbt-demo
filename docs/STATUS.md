# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.cursor/rules/session-handoff.mdc` · Tracker: `DEMO_CHECKLIST.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-17

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Resume here

### Left for you (human)

| # | Item | Where |
|---|------|-------|
| 1 | Re-walk / finalize demo agenda (#11) | `docs/demo-agenda.md` (esp. C2–C3) |
| 2 | Checklist §4 → §10 self-review | `DEMO_CHECKLIST.md` |
| 3 | Optional: `ai-practices.md` → `.agents/skills/` (#6) | noted in `AGENTS.md` |
| 4 | Timed dry run (§10) — do last | `DEMO_CHECKLIST.md` §10 |

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Implemented Pre-review cleanup (decisions locked: shared docs all projects; rich configs + on-run hooks; DELETE+UPDATE hooks + audit; finance incr-of-incr; GHA orchestrate stub; Prefect docs stub; architecture/github rolled into AGENTS/README).
- Verified builds: finance 73 pass / 1 warn; marketing 56; operations 54; incremental + hooks write `audit.dbt_model_hooks` and stamp `loaded_at`.
- Still open for human: finalize agenda walk (#11), §4–§10 checklist, #6 skills migration, dry run.

---

## Snapshot

- **Projects:** `mart_*` at repo root; each has `dev_schema` + `generate_schema_name`, layered schemas, tags/colors/persist_docs, shared `models/docs/*.md`, freshness on `raw_orders`.
- **Finance headline patterns:** incr-of-incr (`*_delta` → `changed_order_ids` → `fct_order_revenue`), model hooks + `audit.dbt_model_hooks`, alias `fct_order_revenue`.
- **Docs:** `architecture.md` / `github.md` removed (content in AGENTS + README). `remaining-work.md` → checklist pointer.
- **Orchestration:** `.github/workflows/orchestrate.yml` (pseudo-runnable); `prefect/README.md` (docs-only).
- **Build:** greened on dev as above (after `--full-refresh`).

---

## Next session

1. Re-walk / finalize demo-agenda (#11).
2. Checklist §4 → §10 self-review with updated content.
3. #6 skills (if time) → dry run.

---

## Open items

Same as **Left for you** above, plus Phase 2+ backlog under `DEMO_CHECKLIST.md` Pre-review cleanup.

---

## Resume quickly

```bash
. ./setup.sh
# Demo Part C:
./scripts/load_raw.sh && cd mart_finance
```

---

## Doc index

| Topic | Path |
|-------|------|
| **Demo + pre-review checklist** | **`DEMO_CHECKLIST.md`** |
| Meeting / demo script | `docs/demo-agenda.md` |
| Exhaustive dbt feature matrix | `docs/dbt-master-checklist.md` |
| Repo overview | `README.md` |
| AI instructions | `AGENTS.md` |
| Backlog pointer | `docs/remaining-work.md` |
