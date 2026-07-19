# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.agents/skills/session-handoff/SKILL.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-19

**Guardrail:** Only the human commits/pushes (see `AGENTS.md`).

---

## Resume here

**Commit + push** `unique`/`not_null` tests on `finance_showcase_kpi` v1/v2 (`_showcase.yml`), then confirm green `main` CI uploads **`dbt-state`**.

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- After re-enable, CI #20 (`a65c8ae`): **bootstrap succeeded** (deps fix worked); failed on **dbt-checkpoint** `check-model-has-tests` for `finance_showcase_kpi_v1` / `_v2` (0 tests).
- Added `unique` + `not_null` on `store_id` per version in `_showcase.yml`; local checkpoint hooks pass.

---

## Snapshot

- CI/bootstrap path should install `dbt_utils` on fresh runners.
- No `dbt-state` artifact on GitHub yet until a green `main` CI after push.
- Checklist removed earlier; agenda A–F still the demo script.

---

## Next session

1. Human: commit + push deps fixes (and any other staged checklist cleanup).
2. Confirm Actions: green `CI` on `main` + **`dbt-state`** artifact.
3. Optional: timed dry run of `docs/demo-agenda.md`.

---

## Open items

| Item | Notes |
|------|--------|
| Uncommitted / unpushed deps fix | Blocks green `main` + artifact |
| Optional dry run | `docs/demo-agenda.md` |
| Phase 2+ | Pages / Docker / broader showcase — agenda Part F |

---

## Resume quickly

```bash
. ./setup.sh
git status   # commit/push deps + prior staged docs if ready
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
