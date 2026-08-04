# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.agents/skills/session-handoff/SKILL.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-08-04

**Guardrail:** Only the human commits/pushes (see `AGENTS.md`).

---

## Resume here

**Demo ready** after push of cold-start + `indirect_selection: cautious` docs. Dry run `docs/demo-agenda.md` (C2 includes mode compare).

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Documented **indirect selection** (eager / buildable / cautious / empty) in `docs/dbt-feature-guide.md` + live `dbt ls` compare in agenda C2.
- Project default: `flags.indirect_selection: cautious` (all `mart_*`) so layered `build --select staging` stays valid.
- Prior: seed + schema cold-start checklist; Windows uv/CRLF fixes.

---

## Snapshot

- Environments: prod + QA shared `prod.duckdb` (`docs/defer.md`).
- Warehouse one-offs: `warehouse/ddl/architectural_ddl.sql`.
- Demo runbook: `docs/demo-agenda.md` · feature map: `docs/dbt-feature-guide.md`.
- `main` CI green; **`dbt-state`** artifact available.

---

## Next session

1. Timed demo dry run (`docs/demo-agenda.md`).
2. Human: commit any remaining local changes before/after dry run.

---

## Open items

| Item | Notes |
|------|--------|
| Demo dry run | Primary next step |
| Phase 2+ backlog | Pages / Docker / observability — README § Planned |

---

## Resume quickly

```bash
. ./setup.sh                 # fresh terminal recommended
./scripts/bootstrap.sh       # prod baseline (skip if warehouse already warm)
# Demo: follow docs/demo-agenda.md from Part A
```

---

## Doc index

| Topic | Path |
|-------|------|
| Environments + defer | `docs/defer.md` |
| Meeting script | `docs/demo-agenda.md` |
| dbt feature map | `docs/dbt-feature-guide.md` |
| AI instructions | `AGENTS.md` |
| Open PR | `.agents/skills/make-pr/SKILL.md` |
