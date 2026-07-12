# dbt_demo — demo walkthrough checklist

Portable checklist for preparing and delivering the demo. Check items off as you go.

**Full runbook (say/show/commands):** `docs/demo-agenda.md`
**Deep-dives:** `docs/dbt-feature-guide.md`, `docs/architecture.md`, `docs/conventions.md`

**Legend:** `[x]` reviewed / ready · `[ ]` not yet · `[~]` in progress · `[↻]` **re-review required** (touched since last walkthrough)

---

## Progress summary

*Update this table when you finish a section. Last updated: 2026-07-12.*

| # | Section | Status | Notes |
|---|---------|--------|-------|
| 1 | Bootstrap — `setup.sh` | **↻ Re-review** | Env only; `.env` path refresh on re-run; no builds, no `exec` |
| 2 | Setup subprocesses + `bootstrap.sh` | **↻ Re-review** | `mart_*` paths in `dbt_build_all.sh`; bootstrap = CI / optional C7 pre-warm only |
| 3 | CI / GitHub (Part B) | **↻ Re-review** | `mart_*` in `.sqlfluff` / pre-commit; Ruff-only Python; skim hooks if audience asks |
| 4 | Repo layout & architecture | **↻ Re-review** | **Start here next week** — `mart_*` at root, `README.md`, architecture, conventions |
| 5 | Data & sources | Not started | Overlaps Part A show-files + C6 |
| 6 | dbt live demo (Part C) | Not started | **One command at a time** — no `bootstrap.sh` on screen; C1–C9 |
| 7 | Production path (Part F) | Not started | Demo vs prod table — agenda updated, not walked |
| 8 | AI workflow (Part D) | Not started | |
| 9 | Wrap (Part E) | Not started | |
| 10 | End-to-end dry run | Not started | Do last — validates everything |

### Re-review required (next week — do before Part C)

These were marked done earlier but **changed during prep**. Re-walk and re-check boxes.

| Section | Why re-review | Focus |
|---------|---------------|-------|
| **§1** | `setup.sh` simplified; `.env` paths refresh on every run | `. ./setup.sh`, no builds, `dbt --version` |
| **§2** | `mart_*` rename; `bootstrap.sh` role clarified | `dbt_build_all.sh` loops `mart_*`; bootstrap not live in demo |
| **§3** | Ruff-only; `mart_*` hook paths; semicolon hook removed | `pre-commit.yml`, `ci.yml`, `.pre-commit-config.yaml` |
| **§4** | Projects moved to root; `README.md` added | `mart_finance/` tree, `dbt_project.yml`, `docs/architecture.md`, `docs/conventions.md` |
| **§6** (when starting) | Demo flow: individual dbt commands, not bootstrap | `cd mart_finance`, `load_raw.sh` then C2–C9; `dbt_docs.sh mart_finance` |

### Done (no re-review needed unless you want a skim)

- [x] **§3** — branch→PR gloss, Slim CI discuss (B4); semicolon hook removed

### Not yet reviewed

- [ ] **§2** — `data/seeds/PROVENANCE.md` (show in Part A)
- [ ] **§2** — `docs/architecture.md` (show in Part A / Part F) — also part of §4 re-review
- [ ] **§3** — `.pre-commit-config.yaml`, `.sqlfluff`, `ruff.toml` (optional deep-dive)
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
| Bootstrap entrypoint | Yes — `. ./setup.sh` (env only) | Re-review §1; dry run on clean machine |
| CI: lint on changed files | Yes — `pre-commit.yml` | Re-review §3; confirm green on a test PR |
| CI: full build + dbt-checkpoint | Yes — `ci.yml` (`setup.sh` → `bootstrap.sh`) | Re-review §3; confirm green on a test PR |
| Multi-env DuckDB | Yes — dev/staging/prod in profile | Decide if staging needs a demo mention |
| Three dbt domains | Yes — `mart_finance`, `mart_marketing`, `mart_operations` | Re-review §4; walk marketing + ops in C9 |
| Docs serve script | Yes — `dbt_docs.sh mart_finance` | Test port 8011 in second terminal |
| Demo runbook | Yes — `docs/demo-agenda.md` | Pre-warm = `setup.sh` only; Part C one command at a time |
| Production path narrative | Yes — Part F in agenda | Walk §7 |
| AI agent config | Yes — `AGENTS.md`, rules | Walk §8 |
| Root `README.md` for humans | **Yes** | Re-review §4 |
| Python lint/format | Yes — Ruff (`ruff.toml`, pre-commit) | Re-review §3 |
| Slim CI in GitHub Actions | **No** (backlog) | Discuss only (B4, C7) |
| GitHub Pages docs deploy | **No** (backlog) | Discuss in C8 |
| `mart_showcase/` | **No** (backlog) | Discuss in C9 |
| Docker / devcontainer | **No** (by design) | Discuss in Part F |
| Observability tooling | **No** (by design) | Discuss in C4 |

**Resume here (next week):** **§4 — repo layout & architecture** (Part C1), then §1–§3 re-review, then §5–§10.

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

## 1. Bootstrap entrypoint — `setup.sh`  [↻ re-review]

- [↻] Lines 1–8: shebang, `set -euo pipefail`, `ROOT`, `cd`
- [↻] Lines 10–15: `uv` prerequisite check
- [↻] Lines 17–18: `uv venv --python=python3.11`
- [↻] Lines 20–30: OS-specific `.venv` activation (use `. ./setup.sh` so activation sticks)
- [↻] Lines 32–33: `uv pip install -e ".[dev]"` → reads `setup.py` + `requirements.json`
- [↻] Lines 35–38: `pre-commit install` (if `.git` exists)
- [↻] Lines 40–48: create `.env` / `profiles.yml` from examples; **refresh path lines** in existing `.env`
- [↻] Line 51: `mkdir -p data`
- [↻] Lines 53–54: `source scripts/env.sh`
- [↻] Lines 56–57: `dbt --version` sanity check
- [↻] No dbt builds in `setup.sh` (builds in `scripts/bootstrap.sh` — CI / optional C7 pre-warm)
- [↻] No interactive `exec` into a project dir (stay at repo root with `. ./setup.sh`)

**Pre-warm (before the room):**
```bash
. ./setup.sh
```

---

## 2. Setup subprocesses (what `setup.sh` calls / depends on)  [↻ re-review]

### Python deps
- [↻] `setup.py` — package metadata, reads `requirements.json`
- [↻] `requirements.json` — `dbt-duckdb`, `duckdb`; dev: `ruff`, `pre-commit` (no Black/Flake8)

### Environment
- [↻] `scripts/env.sh` — load `.env`, export paths, `DBT_DEMO_DBT` / `DBT_DEMO_PYTHON`; default `DBT_PROJECT=mart_finance`
- [↻] `.env.example` → `.env` — machine-specific DuckDB paths, `DBT_TARGET`, docs ports
- [↻] `profiles.yml.example` → `profiles.yml` — `dbt_demo` profile; paths via `env_var()`

### Data pipeline
- [↻] `scripts/scan_downloads.sh` — SHA-256, file type, null bytes, CSV schema
- [↻] `scripts/load_raw.sh` + `scripts/load_raw.py` — CSV → DuckDB `raw.*` (run in Part C / demo, not full bootstrap on screen)
- [↻] `scripts/dbt_build_all.sh` — load raw + `dbt build` for `mart_finance`, `mart_marketing`, `mart_operations`
- [↻] `scripts/bootstrap.sh` — scan + dev build + prod build (**CI** and optional off-line C7 pre-warm — **not** live in demo)

### Supporting files to show in Part A
- [ ] `data/seeds/` + `PROVENANCE.md` (seed provenance)
- [ ] `docs/architecture.md` (data flow diagram)

---

## 3. CI / GitHub (Part B)  [↻ re-review]

### Workflows
- [↻] `.github/workflows/pre-commit.yml` — commit-stage hooks on **changed files only**
  - [↻] `tj-actions/changed-files@v47`
  - [↻] `pre-commit/action@v3.0.1` with `--files …`
  - [↻] Skips when no files changed
- [↻] `.github/workflows/ci.yml` — full bootstrap + dbt-checkpoint
  - [↻] Triggers: PR, push to `main`, `workflow_dispatch`
  - [↻] Job `dbt-build` on `ubuntu-latest`
  - [↻] `actions/checkout@v4`
  - [↻] `astral-sh/setup-uv@v5` (cached)
  - [↻] `./setup.sh` then `./scripts/bootstrap.sh`
  - [↻] Manual-stage hooks: `check-script-has-no-table-name`, `check-model-has-description`, `check-model-has-tests`
  - [↻] Removed `check-script-semicolon` (dbt models must NOT end with `;`)

### Local quality (reference, not a separate demo section)
- [↻] `.pre-commit-config.yaml` — Ruff (lint + format), SQLFluff (`mart_*` paths), shellcheck, shfmt, gitleaks
- [ ] `.sqlfluff` — jinja templater, macro paths under `mart_*`
- [ ] `ruff.toml` — Python lint/format config (Ruff-only; no `pyproject.toml`)

### Git flow (gloss ~30 sec)
- [↻] Branch → push → PR → both workflows run (`docs/github.md`)

### Slim CI in Actions (discuss B4 — not implemented)
- [x] Contrast full `bootstrap.sh` in CI vs local C7 `--defer --state`
- [x] Backlog: manifest artifact from `main`, matrix per domain (`docs/remaining-work.md` Phase 4)

---

## 4. Repo layout & architecture  [↻ re-review — start here next week]

- [ ] Mono-repo: `mart_finance`, `mart_marketing`, `mart_operations` at **repo root** (not `projects/`)
- [ ] Shared `raw.*` in DuckDB; domain-specific marts
- [ ] Root `README.md` — purpose, contents, usage (replaces deleted `projects/README.md`)
- [ ] `docs/architecture.md` — data flow, env table, DuckDB single-writer note
- [ ] `docs/conventions.md` — `{domain}_{layer}_{entity}` naming, PK tests
- [ ] Each `mart_*/dbt_project.yml` — `name: mart_*`, `models: mart_*:` config key

**Part C1 framing (~1 min):** 3 projects at repo root, DuckDB, ~62k orders, full dbt surface not just `dbt run`.

---

## 5. Data & sources

- [ ] `data/seeds/*.csv` — jaffle-shop vendored data
- [ ] `sources.yml` per domain — `raw.*` declarations
- [ ] Source freshness on `raw_orders` (finance) — demo in C6
- [ ] **Discuss:** real ingestion = Fivetran / Airbyte / API, not `load_raw.py`

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
