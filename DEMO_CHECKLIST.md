# dbt_demo — demo walkthrough checklist

Portable checklist for preparing and delivering the demo. Check items off as you go.

**Full runbook (say/show/commands):** `docs/demo-agenda.md`
**Deep-dives:** `docs/dbt-feature-guide.md`, `docs/architecture.md`, `docs/conventions.md`

**Legend:** `[x]` reviewed / ready · `[ ]` not yet · `[~]` in progress · `[↻]` **re-review required** (touched since last walkthrough)

---

## Progress summary

*Update this table when you finish a section. Last updated: 2026-07-13.*

| # | Section | Status | Notes |
|---|---------|--------|-------|
| 1 | Bootstrap — `setup.sh` | **x Done** | Env only; no builds |
| 2 | Setup subprocesses | **N/A** | Files are in git — show in Part A, not a separate review |
| 3 | CI / GitHub (Part B) | **x Done** | Two workflows + Ruff; optional skim of lint config files |
| 4 | Repo layout & architecture | **To do** | `README.md`, `mart_*`, architecture, conventions |
| 5 | Data & sources | **To do** | Seeds, `sources.yml`, freshness |
| 6 | dbt live demo (Part C) | **To do** | One command at a time; C1–C9 |
| 7 | Production path (Part F) | **To do** | Demo vs prod table |
| 8 | AI workflow (Part D) | **To do** | |
| 9 | Wrap (Part E) | **To do** | |
| 10 | End-to-end dry run | **To do** | Do last |

**Resume here:** **§4 — Repo layout & architecture**

### Deferred (mention in demo, not built)

Slim CI in Actions · GitHub Pages docs · `mart_showcase/` · Docker / observability tooling

---

## Meeting order (~50–55 min)

```
Pre-warm: . ./setup.sh only
In room: Part A → Part B → cd mart_finance → Part C (one dbt command at a time)
         → Part F → Part D → Part E → dry run (§10)
```

Second terminal (Part C8): `./dbt_docs.sh mart_finance` → http://127.0.0.1:8011

**Optional off-line:** `./scripts/bootstrap.sh` before the meeting if you want prod manifest ready for C7 defer.

---

## 1. Bootstrap entrypoint — `setup.sh`  [x reviewed]

- [x] Lines 1–9: shebang, `set -euo pipefail`, `ROOT`, `cd`
- [x] Lines 11–16: `uv` prerequisite check
- [x] Lines 18–19: `uv venv --python=python3.11`
- [x] Lines 21–31: OS-specific `.venv` activation (use `. ./setup.sh` so activation sticks)
- [x] Lines 33–34: `uv pip install -e ".[dev]"` → reads `setup.py` + `requirements.json`
- [x] Lines 36–39: `pre-commit install` (if `.git` exists)
- [x] Lines 41–58: create `.env` / `profiles.yml` from examples; **refresh path lines** in existing `.env`
- [x] Line 61: `mkdir -p data`
- [x] Lines 63–64: `source scripts/env.sh`
- [x] Lines 66–67: `dbt --version` sanity check
- [x] No dbt builds in `setup.sh` (builds in `scripts/bootstrap.sh` — CI / optional C7 pre-warm)
- [x] No interactive `exec` into a project dir (stay at repo root with `. ./setup.sh`)

**Pre-warm (before the room):**
```bash
. ./setup.sh
```

---

## 2. Setup subprocesses — N/A (all in git)

No separate checklist step. Every file `setup.sh` depends on is **tracked in git**:

| Area | Files |
|------|-------|
| Python deps | `setup.py`, `requirements.json` |
| Environment | `scripts/env.sh`, `.env.example`, `profiles.yml.example` |
| Data pipeline | `scripts/scan_downloads.sh`, `scripts/load_raw.sh`, `scripts/load_raw.py`, `scripts/dbt_build_all.sh`, `scripts/bootstrap.sh` |
| Seeds | `data/seeds/*.csv`, `checksums.sha256`, `PROVENANCE.md` |

Show these in **Part A** per `docs/demo-agenda.md` — not a standalone review section.

---

## 3. CI / GitHub (Part B)  [x done]

**In the room (~5 min):** open the two workflow files and explain the split. Full script: `docs/demo-agenda.md` Part B.

### What to show

1. **`pre-commit.yml`** — lint on **changed files only** (no `uv`, no `setup.sh`)
   - `changed-files` → `pre-commit/action` runs `pre-commit run --files …`
   - **Ruff** = Python · **SQLFluff** = `mart_*/models/**/*.sql` (see `.pre-commit-config.yaml` + `.sqlfluff`)
   - Local commit + this workflow; dirty Python or model SQL fails the job
2. **`ci.yml`** — full pipeline: `setup-uv` → `./setup.sh` → `./scripts/bootstrap.sh` → dbt-checkpoint
   - Bootstrap builds all three `mart_*` on **dev then prod** (not shown live in the demo)
   - Checkpoint hooks need manifests from that build (descriptions, tests, no raw table names)

### Optional backup (open only if asked)

- `.pre-commit-config.yaml`, `.sqlfluff`, `ruff.toml`
- Branch → PR gloss: `docs/github.md`
- **B4 talk:** CI does a full build; Slim CI (`--defer --state`) is local in C7 / backlog — not in Actions yet

---

## 4. Repo layout & architecture  [↻ re-review]

- [↻] Mono-repo: `mart_finance`, `mart_marketing`, `mart_operations` at **repo root** (not `projects/`)
- [↻] Shared `raw.*` in DuckDB; domain-specific marts
- [↻] Root `README.md` — purpose, contents, usage (replaces deleted `projects/README.md`)
- [↻] `docs/architecture.md` — data flow, env table, DuckDB single-writer note
- [↻] `docs/conventions.md` — `{domain}_{layer}_{entity}` naming, PK tests
- [↻] Each `mart_*/dbt_project.yml` — `name: mart_*`, `models: mart_*:` config key

**Part C1 framing (~1 min):** 3 projects at repo root, DuckDB, ~62k orders, full dbt surface not just `dbt run`.

---

## 5. Data & sources  [↻ re-review]

- [↻] `data/seeds/*.csv` — jaffle-shop vendored data
- [↻] `sources.yml` per domain — `raw.*` declarations
- [↻] Source freshness on `raw_orders` (finance) — demo in C6
- [↻] **Discuss:** real ingestion = Fivetran / Airbyte / API, not `load_raw.py`

---

## 6. dbt live demo — Part C (`cd mart_finance`)  [not started — re-confirm flow when you begin]

**Demo rule:** run commands **one at a time** on screen. Do **not** run `./scripts/bootstrap.sh` in the room.
Load raw when needed: `./scripts/load_raw.sh` (from repo root) before first dbt build/run.

### C2 — DAG (staging → int → marts)
- [ ] `dbt ls --select staging`
- [ ] `dbt ls --select marts`
- [ ] `dbt build --select finance_fct_order_revenue+`
- [ ] Show `models/` tree, `dbt_project.yml` model config

### C3 — Incremental
- [ ] `dbt run --select finance_fct_order_revenue`
- [ ] `dbt run --select finance_fct_order_revenue --full-refresh`
- [ ] Show `finance_fct_order_revenue.sql` — `is_incremental()`, `unique_key`, `delete+insert`

### C4 — Tests
- [ ] `dbt test --select test_type:generic`
- [ ] `dbt test --select test_type:singular`
- [ ] `dbt test --select test_type:unit`
- [ ] Show custom generics: `not_empty_string`, `accepted_range`
- [ ] Show `warn_high_margin_orders` — warn severity + `store_failures`
- [ ] **Discuss:** observability at scale (Elementary, Monte Carlo, etc.)

### C5 — Macros
- [ ] `dbt run-operation audit_relations`
- [ ] Show `audit_relations.sql`, `cents_to_dollars.sql`, `generate_schema_name.sql`

### C6 — Sources, freshness, snapshots
- [ ] `dbt source freshness`
- [ ] `dbt snapshot`
- [ ] Show `finance_snapshot_products`, freshness on `raw_orders`
- [ ] **Discuss:** grants, RLS, model contracts (N/A on DuckDB)

### C7 — Defer + state (headline)
- [ ] Prerequisite: prod manifest exists (optional off-line `./scripts/bootstrap.sh` or prod build before meeting)
- [ ] Capture manifest on `main`: `dbt compile --target-path /tmp/dbt --target prod`
- [ ] Branch change + `dbt build --select state:modified+ --defer --state /tmp/dbt --vars '{"dev_schema":"dev"}' --target prod`
- [ ] Tie back to B4 Slim CI in Actions

### C8 — Docs + exposure
- [ ] Second terminal: `./dbt_docs.sh mart_finance` → http://127.0.0.1:8011
- [ ] Show DAG, `{% docs %}`, `revenue_dashboard` exposure
- [ ] **Discuss:** GitHub Pages deploy (`docs.yml`) — backlog

### C9 — Packages + multi-project
- [ ] `packages.yml` / `dbt deps` / `dbt_utils`
- [ ] `cd ../mart_marketing && dbt build`
- [ ] `cd ../mart_operations && dbt build`
- [ ] **Discuss:** `mart_showcase/` feature lab — backlog Phase 2

### Per-project structure (review as needed)
- [ ] `dbt_project.yml` — profile, paths, materializations
- [ ] `schema.yml` — descriptions, tests
- [ ] Finance-only today: snapshots, exposures, unit tests (`docs/remaining-work.md`)

---

## 7. Production & platform path — Part F (~5 min)

Show `docs/architecture.md` + table in `docs/demo-agenda.md` Part F.

- [ ] **Runtime:** `uv` + setup vs Docker / devcontainer
- [ ] **Infrastructure:** none vs Terraform / cloud IAM
- [ ] **Warehouse:** DuckDB files vs Snowflake / BigQuery / Postgres
- [ ] **Environments:** dev + prod in setup; staging in profile but not demo'd
- [ ] **Ingestion:** `load_raw.py` vs Fivetran / Airbyte
- [ ] **CI PR checks:** pre-commit.yml + full ci.yml vs + Slim CI defer
- [ ] **CI schedule:** manual / cron script vs Airflow / Dagster / dbt Cloud
- [ ] **Observability:** dbt tests vs Elementary / Monte Carlo
- [ ] **Governance:** CI descriptions/tests vs grants / RLS / contracts
- [ ] **Feature lab:** finance-heavy vs `_showcase/` roll-out

---

## 8. AI workflow — Part D (~10 min)

- [ ] `AGENTS.md` — stack, commands, autonomy matrix
- [ ] `.cursor/rules/*.mdc` — auto-loaded Cursor rules
- [ ] `CLAUDE.md` — Claude entry, no MCP
- [ ] `docs/STATUS.md` — session handoff
- [ ] `docs/ai-practices.md` — token patterns
- [ ] `docs/remaining-work.md` — backlog
- [ ] Demo prompt: *"Read `docs/STATUS.md` and continue."*
- [ ] Human commits/pushes only

---

## 9. Wrap — Part E (~3 min)

- [ ] Recap: uv → CI → dbt surface → production path → AI config
- [ ] Point to backlog: Slim CI in Actions, GitHub Pages, `_showcase/`

---

## 10. End-to-end dry run

- [ ] Fresh clone (or clean state)
- [ ] `. ./setup.sh` from repo root (pre-warm only — no bootstrap on screen)
- [ ] Part A show-files; Part B in GitHub Actions tab (or explain from yaml)
- [ ] `cd mart_finance` — `./scripts/load_raw.sh` if needed, then run C2–C7 commands one at a time
- [ ] Second terminal `./dbt_docs.sh mart_finance` for C8
- [ ] Part F table (5 min)
- [ ] Part D files (5–10 min)
- [ ] Total time fits ~50–55 min

---

## Quick command reference

```bash
# Pre-warm (repo root, before the room)
. ./setup.sh

# Optional off-line (C7 defer manifest)
./scripts/bootstrap.sh

# Load raw when starting Part C (repo root)
./scripts/load_raw.sh

# Second terminal (repo root, Part C8)
./dbt_docs.sh mart_finance

# Part C (cd mart_finance)
dbt ls --select staging
dbt ls --select marts
dbt build --select finance_fct_order_revenue+
dbt run --select finance_fct_order_revenue --full-refresh
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select test_type:unit
dbt run-operation audit_relations
dbt source freshness
dbt snapshot

# C7 defer demo
git checkout main
dbt compile --target-path /tmp/dbt --target prod
git checkout <your-branch>
printf '\n-- demo change\n' >> models/marts/finance_fct_daily_revenue.sql
dbt build --select state:modified+ --defer --state /tmp/dbt \
  --vars '{"dev_schema":"dev"}' --target prod
git checkout -- models/marts/finance_fct_daily_revenue.sql
```

---

## Changes made during prep (for reference)

- `setup.sh`: env only; use `. ./setup.sh`; refreshes `.env` path lines on re-run
- `scripts/bootstrap.sh`: scan + dbt build dev + prod — **CI** and optional off-line C7 pre-warm; **not** shown live in demo
- Projects: `projects/{finance,marketing,operations}` → root `mart_finance`, `mart_marketing`, `mart_operations`
- Root `README.md` added; `projects/README.md` removed
- Python: Ruff only (`ruff.toml`, pre-commit `ruff-check` + `ruff-format`)
- Added `.github/workflows/pre-commit.yml` (changed-files + official pre-commit action)
- Removed `check-script-semicolon` from CI and pre-commit config
- Part F (production path) and M-topics woven into `docs/demo-agenda.md`
- Demo Part C: individual dbt commands on screen, not full bootstrap
