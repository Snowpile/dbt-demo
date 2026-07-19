# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.agents/skills/session-handoff/SKILL.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-19

**Guardrail:** Only the human commits/pushes (see `AGENTS.md`).

---

## Resume here

### Demo prep (human)

§1–§9 done. **Next: §10 timed dry run** (~50–55 min) of `docs/demo-agenda.md`.

### Left for you (human)

| # | Item | Where |
|---|------|-------|
| 1 | **§10** timed dry run | `docs/demo-agenda.md` + `DEMO_CHECKLIST.md` §10 |
| 2 | Commit pending changes (AI-agnostic + Part letters + agenda wrap) | human |
| 3 | Confirm `dbt-state` artifact on `main` | Actions tab |
| 4 | After prep: delete `DEMO_CHECKLIST.md` + retarget refs | planned |

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- §7–§9 marked done; Part F backlog no longer points at `DEMO_CHECKLIST.md`.
- AI-agnostic: no `.cursor/rules/`; `CLAUDE.md` = `@AGENTS.md` only.

---

## Snapshot

- Agenda Parts A–F sequential; demo prep checklist §1–§9 complete.
- Uncommitted: AI-agnostic migration + renumber + wrap tweak.

---

## Next session

1. Timed dry run (§10)
2. Human commit + push; Actions artifact check
3. Delete `DEMO_CHECKLIST.md` when prep is truly finished

---

## Open items

Uncommitted work. Phase 2+ backlog copy now only in agenda Part F / STATUS (not pointed at as a live file in the room).

---

## Resume quickly

```bash
. ./setup.sh
./scripts/load_raw.sh && cd mart_finance
```

---

## Doc index

| Topic | Path |
|-------|------|
| Meeting / demo script | `docs/demo-agenda.md` |
| Demo checklist (temp) | `DEMO_CHECKLIST.md` |
| AI instructions | `AGENTS.md` |
| Skills | `.agents/skills/` |
| Defer / slim | `docs/defer.md` |
| Combined Docs DAG | `mart_combined/README.md` |
