# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.agents/skills/session-handoff/SKILL.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-19

**Guardrail:** Only the human commits/pushes (see `AGENTS.md`).

---

## Resume here

Demo dry run **paused**. User wants another **repo pass** first, then the agenda dry run.

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- `main` CI #21 green; **`dbt-state`** artifact live (~27.8 MB).
- Started dress-rehearsal coach at Part A; user paused — prefer repo review before demo.
- Prior: `dbt deps` in scripts; showcase KPI tests for checkpoint.

---

## Snapshot

- `main` CI green (#21); artifact **`dbt-state`** (~27.8 MB) available for Slim CI / PRs.
- Scripts run `dbt deps` before build/compile/clone/docs domain path.
- Checklist removed earlier; agenda A–F still the demo script.

---

## Next session

1. User-led (or assisted) repo pass.
2. Then timed dry run of `docs/demo-agenda.md`.
3. Phase 2+ only if needed.

---

## Open items

| Item | Notes |
|------|--------|
| Repo pass | Before demo dry run |
| Optional dry run | `docs/demo-agenda.md` after pass |
| Phase 2+ | Pages / Docker / broader showcase — agenda Part F |

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
| Meeting script | `docs/demo-agenda.md` |
| Defer / slim | `docs/defer.md` |
| AI instructions | `AGENTS.md` |
| Skills | `.agents/skills/` |
| Combined Docs DAG | `mart_combined/README.md` |
