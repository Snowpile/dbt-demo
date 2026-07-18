# dbt_demo — demo walkthrough checklist

Portable checklist for preparing and delivering the demo. Check items off as you go.

**Full runbook (say/show/commands):** `docs/demo-agenda.md`
**Deep-dives:** `docs/dbt-feature-guide.md`, `docs/conventions.md`, `AGENTS.md` (architecture + GitHub)

**Legend:** `[x]` reviewed / ready · `[ ]` not yet · `[~]` in progress · `[↻]` **re-review required** (touched since last walkthrough)

---

## Progress summary

*Update this table when you finish a section. Last updated: 2026-07-18.*

| # | Section | Status | Notes |
|---|---------|--------|-------|
| — | **Pre-review cleanup** | **Done** (except optional #6) | #11 agenda rewritten; #16 reviewed |
| 1 | Bootstrap — `setup.sh` | **x Done** | Env only; no builds |
| 2 | Setup subprocesses | **N/A** | Files are in git — show in Part A, not a separate review |
| 3 | CI / GitHub (Part B) | **x Done** | + orchestrate.yml stub |
| 4 | Repo layout & architecture | **x Done** | README/AGENTS/conventions + hooks/architectural_ddl |
| 5 | Data & sources | **Re-review** | Freshness on all projects |
| 6 | dbt live demo (Part C) | **To do** | C3: merge preferred; strategies in feature guide |
| 7 | Production path (Part F) | **To do** | Demo vs prod table |
| 8 | AI workflow (Part D) | **To do** | |
| 9 | Wrap (Part E) | **To do** | |
| 10 | End-to-end dry run | **To do** | Do last |

**Resume here (human):**

1. Re-read rewritten `docs/demo-agenda.md` once as presenter
2. Checklist **§5** → §10, then timed dry run
3. Optional #6: `ai-practices.md` → `.agents/skills/`

Also listed in `docs/STATUS.md` → **Left for you**.

### Deferred (mention in demo, not built yet)

Slim CI as PR gate · GitHub Pages docs · `mart_showcase/` · Docker / observability tooling
*(Orchestration stubs — GHA / Prefect / Airflow — are done; mention in Part B/F.)*

---

## Pre-review cleanup

*Absorbs `docs/remaining-work.md` for work that must land before final review. Check off as done. Ask/clarify before implementing ambiguous items.*

**Legend:** `[ ]` todo · `[~]` partial / exists thin · `[x]` done · `[!]` needs decision · `[📝]` note only (do later in sequence)

| # | Item | Status | Notes / current state |
|---|------|--------|------------------------|
| 1 | Shared `{% docs %}` in combined `docs.md` | `[x]` | One `models/docs.md` per project (blocks + applicability comments). |
| 2 | Richer configs at project / schema.yml / model layers | `[x]` | tags, meta, **`docs.node_color`** (DAG color — not `{% docs %}`), persist_docs, schema, vars, on-run; alias. |
| 3 | Source freshness on sources | `[x]` | `raw_orders` freshness in all three projects. |
| 4 | Pre/post hooks on **separate** models + audit | `[x]` | **pre** → `finance_fct_order_revenue`; **post** → `finance_fct_daily_revenue`. |
| 5 | `dev_schema` + `generate_schema_name` in **all** projects | `[x]` | Copied to marketing + operations. |
| 6 | Convert `ai-practices.md` → `.agents/skills`; rest → `AGENTS.md` / `README.md` | `[📝]` | Optional; after agenda / dry-run polish. |
| 7 | Pre-mart gate (build stg+int before marts) | `[x]` | `dbt build` includes attached tests; separate `dbt test` only for selective/custom (C4). |
| 8 | Roll `docs/architecture.md` into `AGENTS.md` + `README.md`, remove | `[x]` | Done; file deleted. |
| 9 | Incremental-of-incrementals (union changed IDs) | `[x]` | Agenda C3 + feature guide; domain uses **`merge`**. |
| 10 | Feature map / where patterns live | `[x]` | `docs/dbt-feature-guide.md` (+ `_showcase/`). |
| 11 | Re-finalize `docs/demo-agenda.md` | `[x]` | Setup in Part A; defer = **C9 last** after marts; leaner say/run/show. |
| 12 | Roll `docs/github.md` into `AGENTS.md` + `README.md`, remove | `[x]` | Done; file deleted. |
| 13 | Roll `docs/remaining-work.md` into this checklist | `[x]` | **Why:** one execution tracker — avoid parallel checklists. |
| 14 | Cleanup `README.md` + sustainable deploy notes | `[x]` | Deploy table fixed; orchestration + `architectural_ddl` noted. |
| 15 | Stub orchestration — **Prefect** | `[x]` | `orchestration/prefect/README.md` + `.[prefect]` extra (not in setup). |
| 16 | Stub orchestration — **GitHub Actions** + **Airflow** | `[x]` | Human reviewed `orchestrate.yml` + Airflow/Prefect stubs. |
| — | Remove unnecessary `.gitkeep` files | `[x]` | Done. |

### Phase 2+ backlog (after pre-review or mention-only)

- [x] Slim CI pattern (`docs/defer.md`, `slim_build.sh`, optional `slim-ci.yml` dispatch) — PR gate stays full bootstrap
- [ ] `mart_showcase/` / spread more features across domains
- [ ] Snapshots / analyses / metrics beyond current finance examples
- [ ] Packages expansion (`dbt_expectations`, etc.) if demo needs them
- [ ] Optional: `pre-commit run --all-files` formatting churn
- [ ] Optional: upload `manifest.json` from `main` as a CI artifact for PR slim builds

### Clarifications still open

None — implement Pre-review cleanup.

---

## Meeting order (~50–55 min)

```
In room: Part A (. ./setup.sh live) → Part B → Part C (defer **last**, after marts) → F → D → E
         → dry run (§10)
```

Second terminal (C7 docs): `./dbt_docs.sh mart_finance` → http://127.0.0.1:8011

No offline bootstrap required for defer — capture manifest after C2+ builds, then C9.

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
- [x] No dbt builds in `setup.sh` (builds in `scripts/bootstrap.sh` — CI only for demo purposes)
- [x] No interactive `exec` into a project dir (stay at repo root with `. ./setup.sh`)

**In room (Part A):**
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
- Branch → PR gloss: `AGENTS.md` (GitHub section)
- **B4 talk:** CI does a full build; Slim CI (`--defer --state`) is local in **C9** after marts (`docs/defer.md`) + optional `slim-ci.yml` — not the PR gate yet
- Orchestration stubs: `orchestrate.yml` + `orchestration/prefect/` + `orchestration/airflow/` (Part C8 / F)

---

## 4. Repo layout & architecture  [x reviewed]

- [x] Mono-repo: `mart_finance`, `mart_marketing`, `mart_operations` at **repo root** (not `projects/`)
- [x] Shared `raw.*` in DuckDB; domain-specific marts
- [x] Root `README.md` — purpose, contents, usage (+ architecture / GitHub rolled in)
- [x] `AGENTS.md` — architecture short + GitHub/PR workflow
- [x] `docs/conventions.md` — `{domain}_{layer}_{entity}` naming, PK tests
- [x] Each `mart_*/dbt_project.yml` — configs, `dev_schema`, tags/colors, on-run hooks

**Part C1 framing (~1 min):** 3 projects at repo root, DuckDB, ~62k orders, full dbt surface not just `dbt run`.

---

## 5. Data & sources  [↻ re-review]

- [↻] `data/seeds/*.csv` — jaffle-shop vendored data
- [↻] `sources.yml` per domain — `raw.*` declarations
- [↻] Source freshness on `raw_orders` in **all three** projects — demo in C6
- [↻] **Discuss:** real ingestion = Fivetran / Airbyte / API, not `load_raw.py`

---

## 6. dbt live demo — Part C (`cd mart_finance`)  [not started — re-confirm flow when you begin]

**Demo rule:** run commands **one at a time** on screen. Do **not** run `./scripts/bootstrap.sh` in the room.
Load raw when needed: `./scripts/load_raw.sh` (from repo root) before first dbt build/run.

### C2 — DAG (staging → int → marts) + pre-mart gate
- [ ] `dbt ls --select staging` / `marts`
- [ ] `dbt build --select staging intermediate` then `dbt build --select marts`
  - (`dbt build` already runs attached tests — no redundant `dbt test` on the same select)
- [ ] Show `dbt_project.yml` configs (tags, **docs.node_color**, persist_docs, vars, on-run hooks)
- [ ] Show project vs schema.yml vs model `config()` layers
- [ ] Show `models/docs.md` (combined `{% docs %}` + `{{ doc() }}`)

### C3 — Incremental (+ incr-of-incr) + hooks on separate models
- [ ] Show `finance_int_orders_delta`, `finance_int_order_items_delta`
- [ ] Show `finance_int_changed_order_ids` — **discuss why** (multi-parent key union)
- [ ] `dbt run --select finance_fct_order_revenue` (+ full-refresh)
- [ ] Show child filter to changed IDs; **`merge`** (preferred); show **append** + merge in `_showcase/`
- [ ] Show **pre_hook** on `finance_fct_order_revenue` (DELETE + audit)
- [ ] Show **post_hook** on `finance_fct_daily_revenue` (UPDATE loaded_at + audit)

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

### C7 — Docs + exposure
- [ ] Second terminal: `./dbt_docs.sh mart_finance` → http://127.0.0.1:8011
- [ ] Show DAG, `{% docs %}`, `revenue_dashboard` exposure
- [ ] **Discuss:** GitHub Pages deploy (`docs.yml`) — backlog

### C8 — Packages + multi-project
- [ ] `packages.yml` / `dbt deps` / `dbt_utils`
- [ ] `cd ../mart_marketing && dbt build` (ops same pattern)
- [ ] Return to `mart_finance` for C9
- [ ] **Discuss:** orchestration stubs (GHA / Prefect / Airflow); `mart_showcase/` — backlog

### C9 — Defer + state (headline, **last**)
- [ ] After C2+ marts exist — `dbt compile --target-path /tmp/dbt`
- [ ] Touch a mart + `dbt build --select state:modified+ --defer --state /tmp/dbt --vars '{"dev_schema":"dev"}'`
- [ ] Tie back to B4 Slim CI; mention prod baseline via `pull_state.sh` / `slim_build.sh`

### Per-project structure (review as needed)
- [ ] `dbt_project.yml` — profile, paths, materializations
- [ ] `schema.yml` — descriptions, tests
- [ ] Finance-only today: snapshots, exposures, unit tests (`docs/remaining-work.md`)

---

## 7. Production & platform path — Part F (~5 min)

Show `README.md` / `AGENTS.md` + table in `docs/demo-agenda.md` Part F. Mention orchestration stubs.

- [ ] **Runtime:** `uv` + setup vs Docker / devcontainer
- [ ] **Infrastructure:** none vs Terraform / cloud IAM
- [ ] **Warehouse:** DuckDB files vs Snowflake / BigQuery / Postgres
- [ ] **Environments:** dev + prod in setup; staging in profile but not demo'd
- [ ] **Ingestion:** `load_raw.py` vs Fivetran / Airbyte
- [ ] **CI PR checks:** pre-commit.yml + full ci.yml vs + Slim CI defer
- [ ] **CI schedule:** `orchestrate.yml` / Prefect / Airflow stubs vs production schedulers
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
- [ ] Part A: `. ./setup.sh` live from repo root (no bootstrap on screen)
- [ ] Part A show-files; Part B in GitHub Actions tab (or explain from yaml)
- [ ] `./scripts/load_raw.sh` then `cd mart_finance` — C2–C8, then **C9 defer last**
- [ ] Second terminal `./dbt_docs.sh mart_finance` for C7
- [ ] Part F table (5 min)
- [ ] Part D files (5–10 min)
- [ ] Total time fits ~50–55 min

---

## Quick command reference

```bash
# Part A (in room, repo root)
. ./setup.sh

# Part C start (repo root)
./scripts/load_raw.sh

# Second terminal (repo root, C7 docs)
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

# C9 defer (after marts built)
dbt compile --target-path /tmp/dbt
printf '\n-- demo change\n' >> models/marts/finance_fct_daily_revenue.sql
dbt build --select state:modified+ --defer --state /tmp/dbt \
  --vars '{"dev_schema":"dev"}'
git checkout -- models/marts/finance_fct_daily_revenue.sql
```

---

## Changes made during prep (for reference)

- `setup.sh`: env only; use `. ./setup.sh`; refreshes `.env` path lines on re-run
- `scripts/bootstrap.sh`: scan + dbt build dev + prod — **CI**; not shown live in demo
- Demo Part C: individual dbt commands; **defer is C9 (last)** after marts + compile
