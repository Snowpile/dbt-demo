# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Backlog: `docs/remaining-work.md` · Meeting script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-07

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Snapshot

- **Repo:** **`dbt_demo`** — local folder, dbt profile, docs, scripts.
- **Build:** green — `./scripts/dbt_build_all.sh` (finance 61/1 warn, marketing 54, operations 52).
- **Setup:** `. ./setup.sh` — venv, config, seed scan, dev + prod builds; source so activation + env stick.
- **Demo prep:** walkthrough checklist at **`DEMO_CHECKLIST.md`** (repo root); runbook at `docs/demo-agenda.md`.
- **CI:** `pre-commit.yml` (changed-file hooks) + `ci.yml` (full `./setup.sh` + dbt-checkpoint).

## Open items (priority)

1. Continue demo walkthrough — **`DEMO_CHECKLIST.md`** (next: #4 repo layout & architecture).
2. Run end-to-end dry run before the meeting.
3. Phase 2+ depth — see `docs/remaining-work.md` (Slim CI in Actions, `_showcase/`, spread finance features).

## Resume quickly

```bash
. ./setup.sh
```

## Doc index

| Topic | Path |
|-------|------|
| **Demo walkthrough checklist** | **`DEMO_CHECKLIST.md`** (progress summary at top) |
| Meeting / demo script | `docs/demo-agenda.md` |
| dbt mechanics (deep-dive) | `docs/dbt-feature-guide.md` |
| AI token patterns | `docs/ai-practices.md` |
| Architecture | `docs/architecture.md` |
| GitHub / PRs | `docs/github.md` |
| Naming | `docs/conventions.md` |
| Full dbt feature matrix | `docs/dbt-master-checklist.md` |
| Backlog | `docs/remaining-work.md` |
