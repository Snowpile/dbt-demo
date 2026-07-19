# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.agents/skills/session-handoff/SKILL.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-19

**Guardrail:** Only the human commits/pushes (see `AGENTS.md`).

---

## Resume here

**Commit + push** the `dbt deps` script fixes so `main` CI can succeed and publish the `dbt-state` artifact.

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Diagnosed `main` CI failure: `bootstrap` → `dbt_build_all` ran `dbt build` without `dbt deps`; `dbt_packages/` gitignored → exit 2 on clean Actions checkout.
- Added `dbt deps` before dbt invokes in: `dbt_build_all.sh`, `slim_build.sh`, `pull_state.sh`, `clone_state.sh`, `dbt_docs.sh` (domain path). `mart_combined` path already had deps.
- Dropped redundant deps loops from `ci.yml` / `slim-ci.yml` (scripts own deps now). Compile step in `ci.yml` still runs deps.

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
