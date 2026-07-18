# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.cursor/rules/session-handoff.mdc` · Tracker: `DEMO_CHECKLIST.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-18

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Resume here

### Feature work

`docs/dbt-master-checklist.md` **deleted**. Durable map is `docs/dbt-feature-guide.md` (+ `_showcase/`, `docs/defer.md`).

**Next:** human demo prep — `DEMO_CHECKLIST.md` §4 layout review (then #16 orchestrate, agenda, dry run).

### Left for you (human)

| # | Item | Where |
|---|------|-------|
| 1 | Finish **§4** layout review | `DEMO_CHECKLIST.md` §4 |
| 2 | **After §4:** review orchestrate + Airflow (#16) | `.github/workflows/orchestrate.yml`, `orchestration/airflow/`, skim `orchestration/prefect/` |
| 3 | Re-check #1 docs.md consolidate, #4 split hooks, #9 incr explain, #14 deploy section | files below |
| 4 | Finalize demo agenda (#11) | `docs/demo-agenda.md` C2–C3 |
| 5 | Checklist §5 → §10 + timed dry run | `DEMO_CHECKLIST.md` |
| 6 | Optional: ai-practices → `.agents/skills/` (#6) | `AGENTS.md` note |

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Folded master-checklist into `docs/dbt-feature-guide.md` / README / conventions; **deleted** `docs/dbt-master-checklist.md`.
- Closed remaining gaps: `selectors.yml`, `adapter.dispatch` on `cents_to_dollars`, `generate_alias_name`, `query-comment` + `dispatch` in finance `dbt_project.yml`, `docs.show` on tests, CLI examples in README.
- Fixed showcase KPI version aliases (`finance_showcase_kpi_v1` / `_v2`).
- Earlier: defer scripts, relationships, unit-test overrides, `_showcase/` config catalog.

---

## Snapshot

- Feature map: `docs/dbt-feature-guide.md` (not a status checklist).
- Showcase: `mart_finance/models/_showcase/`; microbatch needs `concurrent_batches=false`.
- Docs: local only via `./dbt_docs.sh`.

---

## Next session

Human §4 → #16 → agenda finalize → dry run. Large uncommitted batch — human commits when ready.

---

## Open items

Uncommitted work from this multi-session feature push. Human commits when ready.

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
