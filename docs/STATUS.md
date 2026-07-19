# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.agents/skills/session-handoff/SKILL.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-19

**Guardrail:** Only the human commits/pushes (see `AGENTS.md`).

---

## Resume here

`main` CI is green; **`dbt-state`** artifact exists. Optional: timed dry run of `docs/demo-agenda.md`.

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- CI #21 (`bce84a7`) **success** — bootstrap, checkpoint, publish_state, upload **`dbt-state`** (~27.8 MB).
- Prior: deps fix + showcase KPI tests unblocked main.

---

## Snapshot

- `main` CI green (#21); artifact **`dbt-state`** (~27.8 MB) available for Slim CI / PRs.
- Scripts run `dbt deps` before build/compile/clone/docs domain path.
- Checklist removed earlier; agenda A–F still the demo script.

---

## Next session

1. Optional: timed dry run of `docs/demo-agenda.md`.
2. Phase 2+ only if needed (Pages / Docker / showcase).

---

## Open items

| Item | Notes |
|------|--------|
| Optional dry run | `docs/demo-agenda.md` |
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
