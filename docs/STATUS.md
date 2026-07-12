# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Backlog: `docs/remaining-work.md` · Meeting script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-12

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Snapshot

- **Repo:** **`dbt_demo`** — local folder, dbt profile, docs, scripts. Root `README.md` added.
- **Projects:** renamed `projects/{finance,marketing,operations}` → root **`mart_finance` / `mart_marketing` / `mart_operations`** (folder + dbt `name:` + `models:` key). All scripts/configs/docs updated.
- **Build:** green — `./scripts/dbt_build_all.sh` (mart_finance 61/1 warn, mart_marketing 54, mart_operations 52).
- **Setup:** `. ./setup.sh` — venv + config (~1 min). **Bootstrap:** `./scripts/bootstrap.sh` — builds dev + prod.
- **CI:** `pre-commit.yml` + `ci.yml` (`setup.sh` then `bootstrap.sh` + dbt-checkpoint).

## Open items (priority)

1. Continue demo walkthrough — **`DEMO_CHECKLIST.md`** (next: #5 data & sources / #6 Part C).
2. Run end-to-end dry run before the meeting.
3. Phase 2+ depth — see `docs/remaining-work.md` (Slim CI in Actions, `_showcase/`, spread finance features).

## Resume quickly

```bash
. ./setup.sh
./scripts/bootstrap.sh
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
