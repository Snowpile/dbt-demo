# benderik — session summary

*Last updated: 2026-06-26. Read this to pick up where we left off.*

## What this repo is

AI-friendly data engineering sandbox: **3 dbt projects** on **DuckDB**, sharing the richer **dbt-labs/jaffle-shop** star schema. Domains: `finance`, `marketing`, `operations`.

## Done ✓

| Area | Status |
|------|--------|
| AI config | `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/` |
| Sample data | jaffle-shop star schema (customers/orders/items/products/supplies/stores), ~62k orders, SHA-256 pinned + scanned |
| dbt models | per domain: ≥3 stg (view) / 7 int (ephemeral+view+table) / 3 marts (table + **incremental**); **green on dev/staging/prod** (finance 50 / marketing 52 / operations 46 nodes) |
| dbt features | per-domain seed, `cents_to_dollars` macro, `not_negative` custom generic test, `accepted_values` tests |
| Tooling | `uv` + `requirements.json` (`./setup.sh`), `scripts/dbt_build_all.sh`, pre-commit + sqlfluff |
| CI | `.github/workflows/ci.yml` (theoretical) |
| **Local git** | commits on `main` |

## Where we're at

- **Local dbt:** `./scripts/dbt_build_all.sh` builds + seeds all 3 domains on dev/staging/prod
- **Model build-out (Phase 1):** ✅ complete — see `docs/remaining-work.md`
- **Uncommitted:** new seeds/models/macros/tests + pre-commit config (not committed)
- **GitHub push:** **not done yet** — account/SSH mismatch (see below)

## GitHub — pick up here tomorrow

You have **two GitHub accounts** on this machine:

| SSH key | Account |
|---------|---------|
| `~/.ssh/id_rsa_Snowpile` | **Snowpile** ← benderik belongs here |
| `~/.ssh/id_rsa_Hoodie` | ErikRForsman-Hoodie |

`origin` may still point at Hoodie. Fix:

```bash
# 1. Create empty repo "benderik" while logged in as Snowpile on github.com

# 2. Fix remote + push with Snowpile key
cd ~/Desktop/Contracting/benderik
git remote set-url origin git@github.com:Snowpile/benderik.git
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa_Snowpile -o IdentitiesOnly=yes' git push -u origin main
```

Optional: add `~/.ssh/config` with `github-snowpile` / `github-hoodie` hosts (see chat from 2026-06-22).

## Tomorrow — dbt quick start

```bash
cd ~/Desktop/Contracting/benderik
./setup.sh
./scripts/dbt_build_all.sh
```

## Still to do

See `docs/remaining-work.md` for the full prioritized tracker. Headlines:
1. Commit current work; push to GitHub (resolve Snowpile/Hoodie SSH)
2. Advanced dbt features (Phase 2+): snapshots, more incremental strategies (merge/append/microbatch), unit/singular tests, `dbt_utils` package, `_showcase` configs, hooks, exposures
3. Docs pipeline: `dbt docs generate` + `{% docs %}` + GitHub Pages
4. Slim CI + defer with manifest artifacts

## Key files

| File | Purpose |
|------|---------|
| `AGENTS.md` | AI rules + commands |
| `docs/github.md` | PR workflow (update for Snowpile remote) |
| `projects/README.md` | Domain model map |
| `docs/dbt-master-checklist.md` | **Full dbt feature matrix** — implement later |

## For AI

Say: *“Read `summary.md` and continue.”* Do not commit unless asked.
