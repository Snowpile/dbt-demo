# dbt_demo — Current Status (AI handoff)

*Living "where are we / pick up here" file. **Update at the end of every working session.***
*Protocol: `.cursor/rules/session-handoff.mdc` · Tracker: `DEMO_CHECKLIST.md` · Demo script: `docs/demo-agenda.md`*

**Last updated:** 2026-07-18

**Guardrail:** Only the human commits/pushes (see `.cursor/rules/core.mdc`).

---

## Resume here

### Demo prep (human)

Pre-review cleanup is **complete** (including #6 token-lean skill). Slim CI is the **PR gate**.

**Next:** presenter pass on `docs/demo-agenda.md` (esp. B4 / C9), then checklist **§5 → §10** + dry run.

**After you push to `main`:** first successful `publish-state` job creates the `dbt-state` artifact; later PRs slim-build against it.

### Left for you (human)

| # | Item | Where |
|---|------|-------|
| 1 | Presenter pass (B4 Slim CI + C9 defer) | `docs/demo-agenda.md` |
| 2 | Walk checklist **§5** → §10 | `DEMO_CHECKLIST.md` |
| 3 | Timed dry run (§10) | `DEMO_CHECKLIST.md` |
| 4 | Commit + push/merge so `main` publishes `dbt-state` | human commit |

**New chat prompt:** `Read docs/STATUS.md and continue.`

---

## Last session

- Repo cleanup: deleted `docs/remaining-work.md`, `docs/ai-practices.md`, orphan `summary.md`, tracked `.user.yml`.
- Folded token practices → `.agents/skills/token-lean/SKILL.md`; essentials in `AGENTS.md`; retargeted checklist / agenda / rules / README.
- Fixed stale script/CI comments; dropped dead `data/.gitkeep` ignore exceptions; gitignore `.user.yml`.

---

## Snapshot

- Pre-review cleanup: all items `[x]`.
- PR gate = Slim CI; main = full bootstrap + `dbt-state` artifact.
- Defer local demo = C9 after marts; Part A = `. ./setup.sh` only (no bootstrap on screen).
- Large uncommitted batch — human commits when ready.

---

## Next session

1. Presenter re-read agenda B4/C9
2. Checklist §5 → §10 + dry run
3. Human commit + push so main artifact exists

---

## Open items

Uncommitted cleanup (this session + prior). First `main` CI after merge must succeed before PRs get a real slim baseline (fallback = full bootstrap until then).

Phase 2+ (mention-only / later): `mart_showcase/`, more snapshots/analyses, package expansion — see `DEMO_CHECKLIST.md`.

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
| Token-lean skill | `.agents/skills/token-lean/SKILL.md` |
