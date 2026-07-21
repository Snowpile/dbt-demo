# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.agents/skills/session-handoff/SKILL.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-21

**Guardrail:** Only the human commits/pushes (see `AGENTS.md`).

---

## Resume here

User solo repo pass → then demo dry run. Uncommitted: **prod + QA env model** (drop dev/staging), PR template, make-pr skill, CI sanity check, slim-ci removed.

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Aligned repo to **prod + QA only**: shared `prod.duckdb`, `dev_schema` + defer for branch/PR work; removed dev/staging targets and bootstrap dev pass.
- Updated profiles, scripts, macros, defer.md, agenda, README, AGENTS.
- Prior: make-pr skill, PR template, CI green + `dbt-state`.

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
| AI instructions | `AGENTS.md` |
| Open PR | `.agents/skills/make-pr/SKILL.md` |
