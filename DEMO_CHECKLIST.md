# dbt_demo — demo walkthrough checklist

Portable checklist for preparing and delivering the demo. Check items off as you go.

**Full runbook (say/show/commands):** `docs/demo-agenda.md`
**Deep-dives:** `docs/dbt-feature-guide.md`, `docs/architecture.md`, `docs/conventions.md`

**Legend:** `[x]` reviewed / ready · `[ ]` not yet · `[~]` in progress

---

## Progress summary

*Update this table when you finish a section. Last updated: 2026-07-07.*

| # | Section | Status | Notes |
|---|---------|--------|-------|
| 1 | Bootstrap — `setup.sh` | **Done** | Line-by-line review complete |
| 2 | Setup subprocesses | **Done** | Deps, env, config, data scripts reviewed; 2 Part A show-files still open |
| 3 | CI / GitHub (Part B) | **Done** | Workflows reviewed; skim `.pre-commit-config.yaml` / `.sqlfluff` if demo audience asks |
| 4 | Repo layout & architecture | **Next** | Part C1 framing |
| 5 | Data & sources | Not started | Overlaps Part A show-files + C6 |
| 6 | dbt live demo (Part C) | Not started | C2–C9 + per-project structure |
| 7 | Production path (Part F) | Not started | Demo vs prod table — agenda updated, not walked |
| 8 | AI workflow (Part D) | Not started | |
| 9 | Wrap (Part E) | Not started | |
| 10 | End-to-end dry run | Not started | Do last — validates everything |

### Done (reviewed)

- [x] **§1** — full `setup.sh` walkthrough (venv, deps, config, scan, build dev+prod)
- [x] **§2** — `setup.py`, `requirements.json`, `env.sh`, `.env` / `profiles.yml`, `scan_downloads`, `load_raw`, `dbt_build_all`
- [x] **§3** — `pre-commit.yml`, `ci.yml`, branch→PR gloss, Slim CI discuss (B4); removed semicolon hook

### Left to review

- [ ] **§2** — `data/seeds/PROVENANCE.md` (show in Part A)
- [ ] **§2** — `docs/architecture.md` (show in Part A / Part F)
- [ ] **§3** — `.pre-commit-config.yaml`, `.sqlfluff` (optional deep-dive)
- [ ] **§4** — mono-repo layout, `projects/README.md`, `docs/conventions.md`, root README decision
- [ ] **§5** — `sources.yml` per domain, seed files
- [ ] **§6** — all Part C steps C1–C9 + finance project files
- [ ] **§7** — Part F production table (walk + confirm talking points)
- [ ] **§8** — AI files (`AGENTS.md`, rules, STATUS, etc.)
- [ ] **§9** — wrap script
- [ ] **§10** — full dry run timed run-through

### Repo completeness — verify while reviewing

Items to confirm the repo **has** (or consciously defers) before calling the demo ready:

| Area | Have? | Action during review |
|------|-------|----------------------|
| Bootstrap entrypoint | Yes — `. ./setup.sh` | Dry run on clean machine |
| CI: lint on changed files | Yes — `pre-commit.yml` | Confirm green on a test PR |
| CI: full build + dbt-checkpoint | Yes — `ci.yml` | Confirm green on a test PR |
| Multi-env DuckDB | Yes — dev/staging/prod in profile | Decide if staging needs a demo mention |
| Three dbt domains | Yes | Walk marketing + operations in C9 |
| Docs serve script | Yes — `dbt_docs.sh` | Test port 8011 in second terminal |
| Demo runbook | Yes — `docs/demo-agenda.md` | Keep in sync with this checklist |
| Production path narrative | Yes — Part F in agenda | Walk §7 |
| AI agent config | Yes — `AGENTS.md`, rules | Walk §8 |
| Root `README.md` for humans | **No** | Decide: add or point to `summary.md` |
| Slim CI in GitHub Actions | **No** (backlog) | Discuss only (B4, C7) |
| GitHub Pages docs deploy | **No** (backlog) | Discuss in C8 |
| `projects/_showcase/` | **No** (backlog) | Discuss in C9 |
| Docker / devcontainer | **No** (by design) | Discuss in Part F |
| Observability tooling | **No** (by design) | Discuss in C4 |

**Resume here:** **§4 — repo layout & architecture** (Part C1).

---

## Meeting order (~50–55 min)

```
Pre-warm → Part A → Part B → Part C → Part F → Part D → Part E → dry run
```

Second terminal: `./dbt_docs.sh finance` (leave running for C8, port 8011).

---

## 1. Bootstrap entrypoint — `setup.sh`

- [x] Lines 1–8: shebang, `set -euo pipefail`, `ROOT`, `cd`
- [x] Lines 10–15: `uv` prerequisite check
- [x] Lines 17–18: `uv venv --python=python3.11`
- [x] Lines 20–30: OS-specific `.venv` activation (use `. ./setup.sh` so activation sticks)
- [x] Lines 32–33: `uv pip install -e ".[dev]"` → reads `setup.py` + `requirements.json`
- [x] Lines 35–38: `pre-commit install` (if `.git` exists)
- [x] Lines 40–48: create `.env` / `profiles.yml` from examples (first run only)
- [x] Line 51: `mkdir -p data`
- [x] Lines 53–54: `source scripts/env.sh`
- [x] Lines 56–57: `dbt --version` sanity check
- [x] Lines 59–60: `scripts/scan_downloads.sh`
- [x] Lines 62–63: `scripts/dbt_build_all.sh` (dev)
- [x] Lines 65–66: `DBT_TARGET=prod scripts/dbt_build_all.sh` (prod)
- [x] Lines 68–71: completion message + docs hint
- [x] Removed interactive `exec` into `projects/finance` (stay at repo root with `. ./setup.sh`)

**Pre-warm command:**
```bash
. ./setup.sh
```

---

## 2. Setup subprocesses (what `setup.sh` calls / depends on)

### Python deps
- [x] `setup.py` — package metadata, reads `requirements.json`
- [x] `requirements.json` — `dbt-duckdb`, `duckdb`; dev: `ruff`, `pre-commit`

### Environment
- [x] `scripts/env.sh` — load `.env`, export paths, `DBT_DEMO_DBT` / `DBT_DEMO_PYTHON`
- [x] `.env.example` → `.env` — machine-specific DuckDB paths, `DBT_TARGET`, docs ports
- [x] `profiles.yml.example` → `profiles.yml` — `dbt_demo` profile; paths via `env_var()`

### Data pipeline
- [x] `scripts/scan_downloads.sh` — SHA-256, file type, null bytes, CSV schema
- [x] `scripts/load_raw.sh` + `scripts/load_raw.py` — CSV → DuckDB `raw.*`
- [x] `scripts/dbt_build_all.sh` — load raw + `dbt build` for finance, marketing, operations

### Supporting files to show in Part A
- [ ] `data/seeds/` + `PROVENANCE.md` (seed provenance)
- [ ] `docs/architecture.md` (data flow diagram)

---

## 3. CI / GitHub (Part B)

### Workflows
- [x] `.github/workflows/pre-commit.yml` — commit-stage hooks on **changed files only**
  - [x] `tj-actions/changed-files@v47`
  - [x] `pre-commit/action@v3.0.1` with `--files …`
  - [x] Skips when no files changed
- [x] `.github/workflows/ci.yml` — full bootstrap + dbt-checkpoint
  - [x] Triggers: PR, push to `main`, `workflow_dispatch`
  - [x] Job `dbt-build` on `ubuntu-latest`
  - [x] `actions/checkout@v4`
  - [x] `astral-sh/setup-uv@v5` (cached)
  - [x] `./setup.sh`
  - [x] Manual-stage hooks: `check-script-has-no-table-name`, `check-model-has-description`, `check-model-has-tests`
  - [x] Removed `check-script-semicolon` (dbt models must NOT end with `;`)

### Local quality (reference, not a separate demo section)
- [~] `.pre-commit-config.yaml` — ruff, SQLFluff, shellcheck, shfmt, gitleaks (exists; skim if asked)
- [ ] `.sqlfluff` — jinja templater, macro paths

### Git flow (gloss ~30 sec)
- [x] Branch → push → PR → both workflows run (`docs/github.md`)

### Slim CI in Actions (discuss B4 — not implemented)
- [x] Contrast full `./setup.sh` in CI vs local C7 `--defer --state`
- [x] Backlog: manifest artifact from `main`, matrix per domain (`docs/remaining-work.md` Phase 4)

---

## 4. Repo layout & architecture

- [ ] Mono-repo: `projects/finance`, `projects/marketing`, `projects/operations`
- [ ] Shared `raw.*` in DuckDB; domain-specific marts
- [ ] `projects/README.md` — why three projects
- [ ] `docs/architecture.md` — data flow, env table, DuckDB single-writer note
- [ ] `docs/conventions.md` — `{domain}_{layer}_{entity}` naming, PK tests
- [ ] **Discuss:** no root `README.md` for humans (only `AGENTS.md` / `summary.md`) — add?

**Part C1 framing (~1 min):** 3 projects, DuckDB, ~62k orders, full dbt surface not just `dbt run`.

---

## 5. Data & sources

- [ ] `data/seeds/*.csv` — jaffle-shop vendored data
- [ ] `sources.yml` per domain — `raw.*` declarations
- [ ] Source freshness on `raw_orders` (finance) — demo in C6
- [ ] **Discuss:** real ingestion = Fivetran / Airbyte / API, not `load_raw.py`

---

## 6. dbt live demo — Part C (`cd projects/finance`)

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
- [ ] Prerequisite: prod built (pre-warm)
- [ ] Capture manifest on `main`: `dbt compile --target-path /tmp/dbt --target prod`
- [ ] Branch change + `dbt build --select state:modified+ --defer --state /tmp/dbt --vars '{"dev_schema":"dev"}' --target prod`
- [ ] Tie back to B4 Slim CI in Actions

### C8 — Docs + exposure
- [ ] Second terminal: `./dbt_docs.sh finance` → http://127.0.0.1:8011
- [ ] Show DAG, `{% docs %}`, `revenue_dashboard` exposure
- [ ] **Discuss:** GitHub Pages deploy (`docs.yml`) — backlog

### C9 — Packages + multi-project
- [ ] `packages.yml` / `dbt deps` / `dbt_utils`
- [ ] `cd projects/marketing && dbt build`
- [ ] `cd projects/operations && dbt build`
- [ ] **Discuss:** `projects/_showcase/` feature lab — backlog Phase 2

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
- [ ] `. ./setup.sh` from repo root
- [ ] Second terminal `./dbt_docs.sh finance`
- [ ] Walk Part B files in GitHub Actions tab (or explain from yaml)
- [ ] `cd projects/finance` — run C2–C7 commands
- [ ] Part F table (5 min)
- [ ] Part D files (5–10 min)
- [ ] Total time fits ~50–55 min

---

## Quick command reference

```bash
# Pre-warm (repo root)
. ./setup.sh

# Second terminal (repo root)
./dbt_docs.sh finance

# Part C (projects/finance)
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

- `setup.sh`: venv-focused workflow; no `exec` into `projects/finance`; use `. ./setup.sh`
- Added `.github/workflows/pre-commit.yml` (changed-files + official pre-commit action)
- Removed `check-script-semicolon` from CI and pre-commit config
- Part F (production path) and M-topics woven into `docs/demo-agenda.md`
