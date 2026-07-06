# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Backlog: `docs/remaining-work.md` · Meeting script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-05

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Snapshot

- **Repo:** renamed `benderik` → **`dbt_demo`** (local folder, dbt profile, docs, scripts). Remote URL updated locally; **rename on GitHub** (Settings → General) then push.
- **Branch:** `main` · rename changes unstaged (see `git status`).
- **Build:** green — `./scripts/dbt_build_all.sh` (finance 61/1 warn, marketing 54, operations 52).
- **Setup:** `./setup.sh` is the single entrypoint (venv, config, seed scan, dev + prod builds; drops into `projects/finance` with env loaded).
- **Docs:** `docs/demo-agenda.md` is the full meeting runbook (platform + CI + dbt + AI).
  Supporting docs deduped; deep-dives in `docs/dbt-feature-guide.md`, `docs/ai-practices.md`.

## Open items (priority)

1. Run through `docs/demo-agenda.md` before the meeting (pre-warm + Part C defer demo).
2. Optionally spread finance-only features (snapshot, freshness, unit test, exposure) to other domains.
3. Phase 2+ depth — see `docs/remaining-work.md` (Slim CI in Actions, SQLFluff in CI, microbatch, semantic models).

## Resume quickly

```bash
./setup.sh
```

## Doc index

| Topic | Path |
|-------|------|
| Meeting / demo script | `docs/demo-agenda.md` |
| dbt mechanics (deep-dive) | `docs/dbt-feature-guide.md` |
| AI token patterns | `docs/ai-practices.md` |
| Architecture | `docs/architecture.md` |
| GitHub / PRs | `docs/github.md` |
| Naming | `docs/conventions.md` |
| Full dbt feature matrix | `docs/dbt-master-checklist.md` |
| Backlog | `docs/remaining-work.md` |
