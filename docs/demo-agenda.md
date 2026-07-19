# dbt_demo — meeting agenda

~50–55 min. Interactive: talk · run · view.

## Overview

Here's the whole meeting — then we go section by section.


| Part                  | Time       | What we cover                                                                                                              |
| --------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------- |
| **A** Environment     | ~5 min     | `uv` + `setup.sh` live — reproducible local runtime (same entry CI uses)                                                   |
| **B** CI / GitHub     | ~5 min     | Lint on changed files; **main** full build + persist manifests; **PR** Slim CI (`state:modified+`)                         |
| **C** dbt live        | ~20–25 min | Full dbt surface in `mart_finance` — DAG → incrementals → tests → macros → sources → docs → multi-project → **defer last** |
| **D** Production path | ~5 min     | What stays / what swaps for a real warehouse (Docker, Snowflake, grants, schedulers…)                                      |
| **E** AI workflow     | ~10 min    | Repo files as durable context; token-lean agent habits                                                                     |
| **F** Wrap            | ~3 min     | Recap + backlog                                                                                                            |


**Arc:** install → CI mirrors local → dbt end-to-end → map to production → AI in this repo → close.

---

## Part A — Environment (~5 min)

No Docker in this demo — `uv` + one script installs the runtime. CI runs the same setup, then a full bootstrap. Live, we run pieces one at a time.

```bash
. ./setup.sh    # venv → deps → .env / profiles.yml → pre-commit → dbt --version (~1 min)
```

**View:** `requirements.json`, `setup.sh`, `profiles.yml.example` (dev / staging / prod).


| Piece          | Role                                                   |
| -------------- | ------------------------------------------------------ |
| `setup.sh`     | Env only — no warehouse builds                         |
| `bootstrap.sh` | What **CI** runs: scan → load → `dbt build` dev + prod |
| `load_raw.sh`  | CSV → DuckDB `raw.`* (Part C, before first build)      |


Seeds are integrity-checked, then loaded into `raw`. dbt never reads CSVs directly.

```
data/seeds/*.csv  →  load_raw  →  raw.*  →  mart_*  →  stg → int → fct/dim
```

**Demo vs prod (preview D):** `uv` → Docker; DuckDB files → Snowflake/BQ; `load_raw.py` → Fivetran/Airbyte.

---

## Part B — CI / GitHub (~5 min)

**View:** `.github/workflows/pre-commit.yml`, then `ci.yml`.

### B1. Lint workflow

On every PR: lint **changed files only** — same hooks as local commit.

1. `changed-files` → list the diff
2. `pre-commit/action` → `pre-commit run --files …` (runner Python, not our venv)

**Hooks:** **Ruff** (Python) · **SQLFluff** (`mart_*/models/**/*.sql`).

**Optional view:** `.pre-commit-config.yaml` (Ruff + SQLFluff blocks).

### B2. Full CI on `main`

On `main`: install, full bootstrap, structural checks, then **persist** Slim CI baseline.

1. `setup-uv` → `./setup.sh`
2. `./scripts/bootstrap.sh` — scan + load + build **dev + prod**
3. **dbt-checkpoint** — descriptions, tests, no raw table names
4. `publish_state.sh` → upload artifact `**dbt-state`** (`state/*/manifest.json` + `data/prod.duckdb`)

Lint runs even without local `pre-commit install`. Structural checks need a real build.

### B3. Branch → PR (~30 sec)

Branch, push, open PR — lint + Slim CI run on the PR.

### B4. Slim CI on PRs (~1 min)

PRs download main's `**dbt-state**`, then build only `state:modified+` with `--defer`. Unchanged models resolve from the baseline. That's the point of CI at scale. Same flags live in C9. Manual re-run: `slim-ci.yml`.

**View:** `ci.yml` jobs `publish-state` vs `slim-pr` — full build on main vs deferred PR build.

---

## Part C — dbt live (~20–25 min)

One command at a time · never `bootstrap.sh` on screen · second terminal for docs (C7).

```bash
./scripts/load_raw.sh
cd mart_finance
```

### C1. Framing (1 min)

Three dbt projects at repo root, shared DuckDB / jaffle-shop (~62k orders). Goal: full dbt surface — not just `dbt run`. Naming: `docs/conventions.md`.

### C2. DAG — stage → int → mart (3 min)

Layered models. Build and test up to marts, then marts.

```bash
dbt ls --select staging
dbt ls --select marts
dbt build --select staging intermediate    # includes attached tests
dbt build --select marts
# or: dbt build --select +finance_fct_order_revenue
```

**View:** `models/` tree · `dbt_project.yml` (tags, `docs.node_color`, persist_docs, vars, on-run) · config layers (project vs `schema.yml` vs model `config()`).

**Hooks:** **pre** on `finance_fct_order_revenue` · **post** on `finance_fct_daily_revenue`.

Standalone `dbt test` waits for C4 — no re-test of the same select after `dbt build`.

**On marts build:** `WARN` from `warn_high_margin_orders` (~33k rows, `gross_margin_pct > 0.8`). Intentional — `severity: warn`, build still succeeds (`ERROR=0`); `store_failures` → `dev_dbt_test__audit.warn_high_margin_orders`. Dig into it in C4.

### C3. Incrementals (4 min)

```bash
dbt run --select finance_int_orders_delta finance_int_order_items_delta \
  finance_int_changed_order_ids finance_fct_order_revenue
dbt run --select finance_fct_order_revenue --full-refresh
dbt run --select finance_fct_daily_revenue    # post_hook
```

**View this chain:**

1. Parents: `finance_int_orders_delta`, `finance_int_order_items_delta`
2. Key union: `finance_int_changed_order_ids`
3. Child: `finance_fct_order_revenue` — `is_incremental()`, `unique_key`, `**merge`**, `on_schema_change`
4. `_showcase/`: **append** (`finance_showcase_order_log`) · **merge** + predicates (`finance_showcase_store_scd`) · optional microbatch / custom → `docs/dbt-feature-guide.md`

Two incremental parents can each surface different keys. A union of changed IDs gives the child one cheap key list — rebuild only those rows.

### C4. Tests (4 min)

```bash
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select test_type:unit
dbt test --select warn_high_margin_orders
# Peek at stored failures (repo root — second terminal is fine):
./scripts/sql.sh "select * from dev_dbt_test__audit.warn_high_margin_orders limit 10"
```

**View:** custom generics `not_empty_string`, `accepted_range` · `warn_high_margin_orders` (`severity: warn`, `store_failures`) — same WARN as on the C2 marts build.

Hard tests fail the build. This one only warns and stores the bad rows for review — soft fail without blocking the pipeline. At scale: Elementary / Monte Carlo. This repo stops at native tests + `store_failures`.

**Ad-hoc SQL:** `./scripts/sql.sh "…"` from repo root (or `./scripts/sql.sh` for a REPL) — don't `source` it. `data/dev.duckdb` read-only; `-t prod` for prod.

### C5. Macros (2 min)

```bash
dbt run-operation audit_relations
```

**View:** `audit_relations` (`run_query`) · `cents_to_dollars` · `generate_schema_name` · `dbt_utils.generate_surrogate_key` on `finance_fct_daily_revenue`.

### C6. Sources, freshness, snapshots (2 min)

```bash
dbt source freshness
dbt snapshot
```

SCD2 on products; freshness on `raw_orders` in all three projects.

**Governance (~30 sec):** Prod adds **grants**, **RLS**, and **contracts**. Contracts in `_showcase/` (`finance_showcase_store_scd`). Grants/RLS need a real warehouse role model — DuckDB skips them; same project shape ports to Snowflake/BQ. One-off DDL: `scripts/sql/architectural_ddl.sql`.

### C7. Docs + exposure (2 min)

Second terminal, repo root:

```bash
./dbt_docs.sh mart_finance    # http://127.0.0.1:8011
```

**View:** DAG · shared `{% docs %}` in `models/docs.md` · `revenue_dashboard` exposure.

**All-domain DAG (optional):** `./dbt_docs.sh mart_combined` → [http://127.0.0.1:8010](http://127.0.0.1:8010) — finance + marketing + operations in one graph (docs-only project; not in CI).

### C8. Packages + multi-project (1 min)

`dbt_utils` via `packages.yml`. Same patterns in marketing and operations.

```bash
cd ../mart_marketing && dbt build
cd ../mart_finance     # back for defer
```

**Orchestration (~30 sec):** Stubs — `orchestrate.yml`, Prefect, Airflow (still the industry default). CI gates PRs; orchestration schedules the same scripts.

### C9. Defer + state (3 min) — headline, **last**

Marts already built (C2+) → baseline `manifest.json` is meaningful. Detail: `docs/defer.md`.

We've built the project. Capture that as the baseline (like `main` / prod). Change one model — rebuild only that change; everything else resolves via `--defer`.

```bash
# Still in mart_finance — marts already on **dev** from C2+
dbt compile --target-path /tmp/dbt

printf '\n-- demo change\n' >> models/marts/finance_fct_daily_revenue.sql

dbt build --select state:modified+ --defer --state /tmp/dbt \
  --vars '{"dev_schema":"dev"}'

git checkout -- models/marts/finance_fct_daily_revenue.sql
```

Same flags Actions uses on PRs. In GitHub, the baseline is the `**dbt-state**` artifact from `main` (`publish_state.sh` + `prod.duckdb`). Here we use the marts we just built so the lesson is clear in one terminal.

---

## Part D — Production path (~5 min)

Local and small on purpose. Same repo shape; swap the runtime.


| Topic         | This demo                                            | Typical production                                              |
| ------------- | ---------------------------------------------------- | --------------------------------------------------------------- |
| Runtime       | `uv` + `setup.sh`                                    | Docker / same `requirements.json`                               |
| Infra         | Local files                                          | Terraform / cloud IAM                                           |
| Warehouse     | DuckDB per env                                       | Snowflake, BigQuery, Postgres                                   |
| Envs          | Profile has staging; CI builds dev + prod            | Promote path + secrets per target                               |
| Ingestion     | Vendored CSV + `load_raw`                            | Fivetran / Airbyte / APIs                                       |
| PR CI         | Slim CI vs main `dbt-state` artifact                 | Same pattern (manifest from `main`; warehouse already has prod) |
| Schedule      | GHA / Prefect / Airflow stubs                        | Same tools, real schedules                                      |
| Observability | dbt tests + `store_failures`                         | Elementary / Monte Carlo                                        |
| Governance    | Descriptions + tests in CI; contract in `_showcase/` | Grants, RLS, contracts on warehouse                             |
| Feature lab   | Finance-heavy + `_showcase/`                         | Broader `mart_showcase/`                                        |


DuckDB stays free and offline. Projects, tests, and CI patterns transfer — only the profile and scheduler change.

---

## Part E — AI workflow (~10 min)

Durable context lives in files, not chat history — **tool-agnostic**.

| Layer | File |
|-------|------|
| Source of truth | `AGENTS.md` |
| Skills (workflows) | `.agents/skills/*/SKILL.md` |
| Claude shim | `CLAUDE.md` → `@AGENTS.md` only (Claude Code does not read `AGENTS.md` natively) |
| Session handoff | `docs/STATUS.md` (+ session-handoff skill) |
| Demo script | `docs/demo-agenda.md` |

- `@`-reference / name paths — don't paste logs
- Scoped asks — "fix X in `finance_fct_order_revenue`"
- Fresh chat when stale — resume via `STATUS.md`
- Don't re-explain the stack — `AGENTS.md` already loads it
- Subagents for broad exploration; parent synthesizes
- Human only commits / pushes
- No MCP — terminal + repo files only

| | Cursor / most agents | Claude Code |
|---|--------|-------------|
| Entry | `AGENTS.md` + `.agents/skills/` | `CLAUDE.md` → `@AGENTS.md` |
| File refs | `@path` | path in prompt |
| MCP | unused here | disabled |

**New-chat prompt:** `Read docs/STATUS.md and continue.`

---

## Part F — Wrap (~3 min)

**Recap:** env from `setup.sh` → CI mirrors local → full dbt surface → prod path → AI keeps tokens low.

**Backlog (mention-only):** GitHub Pages docs · Docker / observability · broader `mart_showcase/` feature lab.

---

## Command cheat sheet

```bash
# Part A
. ./setup.sh

# Part C
./scripts/load_raw.sh
cd mart_finance
dbt ls --select staging
dbt build --select staging intermediate
dbt build --select marts
dbt run --select finance_fct_order_revenue --full-refresh
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select test_type:unit
dbt run-operation audit_relations
dbt source freshness
dbt snapshot
./dbt_docs.sh mart_finance   # C7 — second terminal
# C9 defer (after marts built)
dbt compile --target-path /tmp/dbt
printf '\n-- demo change\n' >> models/marts/finance_fct_daily_revenue.sql
dbt build --select state:modified+ --defer --state /tmp/dbt --vars '{"dev_schema":"dev"}'
git checkout -- models/marts/finance_fct_daily_revenue.sql
```
