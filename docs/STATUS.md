# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.cursor/rules/session-handoff.mdc` · Tracker: `DEMO_CHECKLIST.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-18

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Resume here

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

- README: Airflow + Prefect + GHA links; fixed misleading pre-mart `dbt test`; removed master-checklist blurb.
- Added `orchestration/airflow/` stub (with Prefect under `orchestration/`); optional `.[prefect]` / `.[airflow]` extras + `_commented_out_orchestration_note` in `requirements.json`.
- Agenda/checklist/AGENTS aligned (build includes tests; Airflow in orchestration story).

---

## Snapshot

- Docs: one `mart_*/models/docs.md` each (not per-field files).
- Hooks: **pre** on `finance_fct_order_revenue`, **post** on `finance_fct_daily_revenue`.
- `docs.node_color` = dbt Docs DAG color config (under `docs:` key), distinct from `{% docs %}` blocks.
- README includes sustainable deployment + orchestration stubs under `orchestration/{prefect,airflow}/` + GHA.
- `dbt build` includes attached tests; standalone `dbt test` reserved for selective/custom (C4).

---

## Next session

Continue human §4 → #16 orchestrate → agenda finalize → §5–§10 → dry run.

---

## Open items

Same as **Left for you** above.

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
| **Demo + pre-review checklist** | **`DEMO_CHECKLIST.md`** |
| Meeting / demo script | `docs/demo-agenda.md` |
| Exhaustive dbt feature matrix | `docs/dbt-master-checklist.md` |
| Repo overview | `README.md` |
| AI instructions | `AGENTS.md` |
