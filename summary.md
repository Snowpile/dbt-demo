# benderik — session summary

*Last updated: 2026-06-22 (evening). Read this tomorrow to pick up where we left off.*

## What this repo is

AI-friendly data engineering sandbox: **3 dbt projects** on **DuckDB**, sharing official **Jaffle Shop** sample data. Domains: `finance`, `marketing`, `operations`.

## Done ✓

| Area | Status |
|------|--------|
| AI config | `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/` |
| Sample data | Jaffle Shop CSVs in `data/seeds/`, SHA-256 pinned + scanned |
| dbt models | stg → int → fct/dim per domain; **49 tests passing** on dev |
| Tooling | `uv` + `uv.lock`, `scripts/dbt_build_all.sh` |
| CI | `.github/workflows/ci.yml` |
| **Local git** | **First commit on `main`** (`be75f79`) |

## Where we're at

- **Local dbt:** `./scripts/dbt_build_all.sh` works
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
uv sync
export DBT_PROFILES_DIR=$(git rev-parse --show-toplevel)
./scripts/dbt_build_all.sh
```

## Still to do (after push)

1. Confirm CI passes on GitHub Actions after first push
2. Cron for `dbt_build_all.sh` (optional)
3. Staging/prod DuckDB targets (untested)
4. Richer `schema.yml` docs / `dbt docs generate`
5. Real data when ready

## Key files

| File | Purpose |
|------|---------|
| `AGENTS.md` | AI rules + commands |
| `docs/github.md` | PR workflow (update for Snowpile remote) |
| `projects/README.md` | Domain model map |
| `docs/dbt-master-checklist.md` | **Full dbt feature matrix** — implement later |

## For AI

Say: *“Read `summary.md` and continue.”* Do not commit unless asked.
