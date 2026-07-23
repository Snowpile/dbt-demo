# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.agents/skills/session-handoff/SKILL.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-22

**Guardrail:** Only the human commits/pushes (see `AGENTS.md`).

---

## Resume here

Human reviewing **scripts/** + **root** via `docs/scripts-and-root.md`. Uncommitted: env alignment, docs (versions/unit tests/YAML), `warehouse/ddl/` move, README planned backlog.

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Moved `architectural_ddl.sql` → **`warehouse/ddl/`**; updated all refs.
- Added **`docs/scripts-and-root.md`** (catalog of every `scripts/` + root file).
- Prior: unit tests vs macros; YAML placement; model versions; env alignment.

---

## Snapshot

- Environments: `docs/defer.md` § Environments (prod + QA; no dev.duckdb).
- `main` CI green; **`dbt-state`** artifact available.
- PR workflow: `.agents/skills/make-pr/SKILL.md` after human push.

---

## Next session

1. Human: commit env alignment + other staged work.
2. Optional: timed dry run of `docs/demo-agenda.md` (Part C now uses `--target prod`).

---

## Open items

| Item | Notes |
|------|--------|
| Commit env + PR tooling | profiles, bootstrap, docs, make-pr |
| Optional dry run | `docs/demo-agenda.md` |
| Phase 2+ | Pages / Docker — agenda Part F |

---

## Resume quickly

```bash
. ./setup.sh
./scripts/bootstrap.sh   # prod baseline only
```

---

## Doc index

| Topic | Path |
|-------|------|
| Environments + defer | `docs/defer.md` |
| Meeting script | `docs/demo-agenda.md` |
| Scripts & root files | `docs/scripts-and-root.md` |
| AI instructions | `AGENTS.md` |
| Open PR | `.agents/skills/make-pr/SKILL.md` |
