# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Backlog: `docs/remaining-work.md` · Meeting script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-12

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Snapshot

- **Repo:** `dbt_demo` — root `README.md`, scripts, docs, CI.
- **Projects:** `mart_finance`, `mart_marketing`, `mart_operations` at **repo root** (not under `projects/`).
- **Setup:** `. ./setup.sh` — venv + config only (~1 min). No dbt builds in setup.
- **Bootstrap:** `./scripts/bootstrap.sh` — scan + load raw + dbt build dev + prod. **CI only** / optional pre-warm for C7 defer — **not** shown live in the demo room.
- **Demo flow:** Part C runs dbt commands **one at a time** from `cd mart_finance` (after `load_raw.sh` as needed).
- **Python lint/format:** Ruff only (`ruff.toml`, pre-commit `ruff-check` + `ruff-format`).
- **Build:** green via `bootstrap.sh` (mart_finance 61/1 warn, mart_marketing 54, mart_operations 52).
- **CI:** `pre-commit.yml` (changed files) + `ci.yml` (`setup.sh` → `bootstrap.sh` → dbt-checkpoint).

---

## Next session (finish demo prep)

**Primary doc:** `DEMO_CHECKLIST.md` — see **Re-review required** and **Progress summary** at the top.

**Order for next week:**

1. **§4** — repo layout (`mart_*`, `README.md`, `dbt_project.yml`, architecture, conventions)
2. **§1–§3** — quick re-review after restructure (setup, scripts, CI, Ruff)
3. **§5** — data & sources
4. **§6** — Part C live demo (C1–C9), one command at a time
5. **§7–§9** — Part F, D, wrap
6. **§10** — timed end-to-end dry run

---

## Open items

1. Complete re-review sections in `DEMO_CHECKLIST.md` (§1–§4 minimum before Part C).
2. Align `docs/demo-agenda.md` Part C steps with live one-command-at-a-time flow.
3. End-to-end dry run (~50–55 min) before the meeting.
4. Phase 2+ backlog: `docs/remaining-work.md` (Slim CI in Actions, `mart_showcase/`, spread finance features).

---

## Resume quickly

```bash
. ./setup.sh
cd mart_finance
# Demo: ./scripts/load_raw.sh  then dbt commands per docs/demo-agenda.md Part C
```

---

## Doc index

| Topic | Path |
|-------|------|
| **Demo walkthrough checklist** | **`DEMO_CHECKLIST.md`** |
| Meeting / demo script | `docs/demo-agenda.md` |
| Repo overview (humans) | `README.md` |
| dbt mechanics (deep-dive) | `docs/dbt-feature-guide.md` |
| AI token patterns | `docs/ai-practices.md` |
| Architecture | `docs/architecture.md` |
| GitHub / PRs | `docs/github.md` |
| Naming | `docs/conventions.md` |
| Full dbt feature matrix | `docs/dbt-master-checklist.md` |
| Backlog | `docs/remaining-work.md` |
