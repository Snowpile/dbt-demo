# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.cursor/rules/session-handoff.mdc` · Tracker: `DEMO_CHECKLIST.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-18

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Resume here

### Demo prep (human)

Slim CI is now the **PR gate** (manifest + `prod.duckdb` artifact from `main`). Agenda/docs updated.

**Next:** presenter pass on `docs/demo-agenda.md` (esp. B4 / C9), then checklist **§5 → §10** + dry run.

**After you push to `main`:** first successful `publish-state` job creates the `dbt-state` artifact; later PRs slim-build against it.

### Left for you (human)

| # | Item | Where |
|---|------|-------|
| 1 | Presenter pass (B4 Slim CI + C9 defer) | `docs/demo-agenda.md` |
| 2 | Walk checklist **§5** → §9 | `DEMO_CHECKLIST.md` |
| 3 | Timed dry run (§10) | `DEMO_CHECKLIST.md` |
| 4 | Push/merge so `main` publishes `dbt-state` | human commit |
| 5 | Optional: ai-practices → `.agents/skills/` (#6) | `AGENTS.md` note |

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Implemented **persisted Slim CI**: `ci.yml` on `main` uploads `dbt-state` (`state/*/manifest.json` + `data/prod.duckdb`); PRs download and run `state:modified+ --defer`.
- Scripts: `publish_state.sh`, `slim_build_all.sh`. `slim-ci.yml` = manual re-run.
- Docs: `defer.md`, README, AGENTS, agenda B4/C9, checklist.

---

## Snapshot

- PR gate = Slim CI; main = full bootstrap + artifact.
- Defer local demo = C9 after marts; setup = Part A in-room.
- Large uncommitted batch — human commits when ready.

---

## Next session

1. Presenter re-read agenda B4/C9
2. Checklist §5 → §10 + dry run
3. Human push so main artifact exists
4. Optional #6 ai-practices fold

---

## Open items

Uncommitted work. First `main` CI after merge must succeed before PRs get a real slim baseline (fallback = full bootstrap until then).

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
