# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.agents/skills/session-handoff/SKILL.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-19

**Guardrail:** Only the human commits/pushes (see `AGENTS.md`).

---

## Resume here

### Human

Repo review / prep walkthrough **§1–§9 done**. Optional **§10** dry run, then ship.

1. Commit leftover: `docs/defer.md` (clone slim-down) + `.gitignore` / `.cursorignore` cleanup
2. Confirm Actions: `main` has **`dbt-state`** artifact
3. Optional: timed dry run (`docs/demo-agenda.md` ~50–55 min) — `DEMO_CHECKLIST.md` §10
4. After you’re satisfied: **delete `DEMO_CHECKLIST.md`** and retarget any remaining refs (STATUS / README / AGENTS)

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Final cleanup: commented `.gitignore`, aligned `.cursorignore`, slimmed `dbt clone` in `docs/defer.md`.
- Demo agenda Parts A–F reviewed; AI-agnostic (`AGENTS.md` + `.agents/skills/`; `CLAUDE.md` = `@AGENTS.md`).

---

## Snapshot

- Pre-review + presenter walk §1–§9 complete.
- Slim CI + `mart_combined` docs DAG + `sql.sh` in place.
- Uncommitted: `docs/defer.md`, `.gitignore`, `.cursorignore` (± STATUS).

---

## Open items

| Item | Notes |
|------|--------|
| Commit / push cleanup | human |
| `dbt-state` on `main` | Actions tab |
| §10 dry run | optional but recommended once |
| Remove `DEMO_CHECKLIST.md` | after dry run / when prep closed |
| Phase 2+ | Pages, Docker, broader showcase — mention-only in agenda Part F |

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
| Checklist (temp) | `DEMO_CHECKLIST.md` |
| Combined Docs DAG | `mart_combined/README.md` |
