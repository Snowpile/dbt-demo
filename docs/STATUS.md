# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.cursor/rules/session-handoff.mdc` · Backlog: `docs/remaining-work.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-17

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Resume here

**`DEMO_CHECKLIST.md` §4 — repo layout & architecture** (human self-review; not started yet).

Then §5 → §6 (Part C) → §7–§9 → §10 dry run.

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Demo-prep walkthrough of `DEMO_CHECKLIST.md`. User reviewing personally (not agent auto-checking).
- **§1 done** (`setup.sh`). **§2 N/A** (all deps in git — show in Part A). **§3 done** (CI/GitHub).
- Clarified Part B: `pre-commit.yml` (changed-files lint, no uv) vs `ci.yml` (setup → bootstrap → dbt-checkpoint). Ruff fails dirty Python; SQLFluff on `mart_*/models/**/*.sql` via same pre-commit hooks — noted in `docs/demo-agenda.md` Part B + checklist §3.
- Cleaned confusing progress-table / re-review notes at top of checklist.
- Listed §4 review items for user; paused before walking them.

---

## Snapshot

- **Repo:** `dbt_demo` — root `README.md`, scripts, docs, CI.
- **Projects:** `mart_finance`, `mart_marketing`, `mart_operations` at **repo root** (not under `projects/`).
- **Setup:** `. ./setup.sh` — venv + config only (~1 min). No dbt builds in setup.
- **Bootstrap:** `./scripts/bootstrap.sh` — scan + load raw + dbt build dev + prod. **CI only** / optional pre-warm for C7 defer — **not** shown live in the demo room.
- **Demo flow:** Part C runs dbt commands **one at a time** from `cd mart_finance` (after `load_raw.sh` as needed).
- **Lint:** Ruff (Python) + SQLFluff (model SQL) via `.pre-commit-config.yaml` → local commit + `pre-commit.yml`.
- **CI:** `pre-commit.yml` (changed files) + `ci.yml` (`setup.sh` → `bootstrap.sh` → dbt-checkpoint).
- **Build:** last known green via `bootstrap.sh` (mart_finance 61/1 warn, mart_marketing 54, mart_operations 52).

---

## Next session (finish demo prep)

**Primary doc:** `DEMO_CHECKLIST.md`

1. **§4** — layout: tree, `README.md`, `docs/architecture.md`, `docs/conventions.md`, each `mart_*/dbt_project.yml` + C1 framing
2. **§5** — seeds, `sources.yml`, freshness
3. **§6** — Part C live demo (C1–C9), one command at a time
4. **§7–§9** — Part F, D, wrap
5. **§10** — timed dry run (~50–55 min)

---

## Open items

1. Complete `DEMO_CHECKLIST.md` §4–§10.
2. End-to-end dry run before the meeting.
3. Phase 2+ backlog: `docs/remaining-work.md` (Slim CI in Actions, `mart_showcase/`, spread finance features).

---

## Resume quickly

```bash
. ./setup.sh
# Then open DEMO_CHECKLIST.md §4 — or for Part C:
# ./scripts/load_raw.sh && cd mart_finance
```

---

## Doc index

| Topic | Path |
|-------|------|
| **Demo walkthrough checklist** | **`DEMO_CHECKLIST.md`** |
| Session handoff protocol | `.cursor/rules/session-handoff.mdc` |
| Meeting / demo script | `docs/demo-agenda.md` |
| Repo overview (humans) | `README.md` |
| dbt mechanics (deep-dive) | `docs/dbt-feature-guide.md` |
| AI token patterns | `docs/ai-practices.md` |
| Architecture | `docs/architecture.md` |
| GitHub / PRs | `docs/github.md` |
| Naming | `docs/conventions.md` |
| Full dbt feature matrix | `docs/dbt-master-checklist.md` |
| Backlog | `docs/remaining-work.md` |
