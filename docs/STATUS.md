# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.cursor/rules/session-handoff.mdc` · Tracker: `DEMO_CHECKLIST.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-18

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Resume here

### Demo prep (human)

Agenda rewritten (#11). Pre-review cleanup done except optional #6.

**Next:** re-read `docs/demo-agenda.md` once as presenter (defer is **C9**, after marts), then checklist **§5 → §10** + timed dry run.

### Left for you (human)

| # | Item | Where |
|---|------|-------|
| 1 | Presenter pass on rewritten agenda | `docs/demo-agenda.md` |
| 2 | Walk checklist **§5** (data & sources) → §9 | `DEMO_CHECKLIST.md` |
| 3 | Timed end-to-end dry run (§10) | `DEMO_CHECKLIST.md` |
| 4 | Optional: ai-practices → `.agents/skills/` (#6) | `AGENTS.md` note |

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Agenda: **defer moved to C9 (end of Part C)** — build marts first, `dbt compile` for manifest, then `--defer`. No offline bootstrap for defer.
- Earlier: `. ./setup.sh` in Part A (in-room); leaner say/run/show rewrite.

---

## Snapshot

- Feature map: `docs/dbt-feature-guide.md` (+ `_showcase/`).
- Domain incrementals: `merge`. Demo setup live in Part A; defer last after marts.
- Orchestration stubs reviewed.
- Large uncommitted batch — human commits when ready.

---

## Next session

1. Presenter re-read of agenda (esp. C9 defer flow)
2. Checklist §5 → §10 + dry run
3. Optional #6 ai-practices fold

---

## Open items

Uncommitted work from multi-session feature push. Human commits when ready.

---

## Resume quickly

```bash
. ./setup.sh
./scripts/load_raw.sh && cd mart_finance
dbt list --select selector:finance_showcase
```

---

## Doc index

| Topic | Path |
|-------|------|
| **Demo + pre-review checklist** | **`DEMO_CHECKLIST.md`** |
| Meeting / demo script | `docs/demo-agenda.md` |
| dbt feature map / CLI | `docs/dbt-feature-guide.md` |
| Defer / slim / clone | `docs/defer.md` |
| Repo overview | `README.md` |
| AI instructions | `AGENTS.md` |
