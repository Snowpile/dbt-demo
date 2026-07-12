# dbt_demo — meeting agenda (step-by-step runbook)

~50–55 min. Each step has **say** (the point) and **run** / **show** (what to do).
Deep-dives: `docs/dbt-feature-guide.md` (dbt mechanics), `docs/ai-practices.md` (AI patterns).

> **macOS / Linux / Windows (Git Bash / WSL).** On Windows use Git Bash for `./*.sh`.

---

## Pre-warm (before the room, ~5 min)

**Say:** "Two steps — environment, then warehouse builds."

```bash
. ./setup.sh              # venv, config, dbt --version (~1 min)
./scripts/bootstrap.sh    # seed scan + load raw + dbt build dev + prod (~4 min)
```

Open a **second terminal** for `./dbt_docs.sh mart_finance` (Part C8 — blocks on port 8011).

*Optional:* run `./scripts/bootstrap.sh` **live in the room** during Part A instead of pre-warming.

---

## Part A — Reproducible environment (~5 min)

**Say:** "We don't ship a Docker image in this demo — **`uv` + `./setup.sh`** installs the runtime;
**`./scripts/bootstrap.sh`** runs the data pipeline (scan → load → build). CI runs both.
In production you'd wrap the same `requirements.json` in a container."

| Piece | Role |
|---|---|
| `requirements.json` + `setup.py` | Pinned deps (`dbt-duckdb`, `duckdb`); dev extras (`ruff`, `pre-commit`) |
| `./setup.sh` | `uv venv` → install → copy `.env` / `profiles.yml` → `pre-commit install` → `dbt --version` |
| `./scripts/bootstrap.sh` | `scan_downloads` → `load_raw` → `dbt build` dev + prod (all domains) |
| `scripts/env.sh` | Exports `DBT_PROFILES_DIR`, DuckDB paths, venv bin (`.venv/bin` or `.venv/Scripts`) |
| `.env` / `profiles.yml` | Local paths (gitignored); one DuckDB **file per env** (dev / staging / prod) |

**Show:** `profiles.yml.example` — three targets; demo builds **dev + prod** in setup; **staging**
exists for promote-path discussion (Part F).

**Discuss (demo vs prod — preview Part F):**

| This demo | Typical production |
|-----------|-------------------|
| `uv` + `./setup.sh` | Same deps in a **Docker** image or devcontainer |
| Local DuckDB files | **Snowflake / BigQuery / Postgres** via Terraform or cloud IAM |
| `load_raw.py` from CSV | Ingestion tool (Fivetran, Airbyte, custom pipeline) |

**Show:** `requirements.json`, `setup.sh`, `profiles.yml.example`.

**Say:** "Raw CSVs are integrity-checked (`scan_downloads.sh`: SHA-256, MIME, UTF-8) then loaded
into DuckDB schema `raw` (`load_raw.sh` → `load_raw.py`). dbt never reads CSVs directly."

Data flow (see `docs/architecture.md` for detail):

```
data/seeds/*.csv  →  load_raw.py  →  raw.*  →  mart_<domain>/models  →  stg → int → fct/dim
```

---

## Part B — CI/CD & GitHub (~5 min)

**Show:** `.github/workflows/pre-commit.yml` then `.github/workflows/ci.yml`

**Say:** "Two workflows on every PR / push to `main`:"

**`pre-commit.yml`** — same hooks as local `git commit` (for devs without pre-commit installed):

1. `actions/checkout`
2. `astral-sh/setup-uv` (cached)
3. `tj-actions/changed-files` — list files in the PR / push
4. `pre-commit/action` with `--files …` — commit hooks on **changed files only** (skips if none)

**`ci.yml`** — environment + warehouse bootstrap (same as local pre-warm):

1. `actions/checkout`
2. `astral-sh/setup-uv` (cached)
3. `./setup.sh` — venv, config, `dbt --version`
4. `./scripts/bootstrap.sh` — scan seeds + load raw + `dbt build` dev + prod
5. **dbt-checkpoint** manual-stage hooks (need manifests from step 4):
   `check-script-has-no-table-name`, `check-model-has-description`,
   `check-model-has-tests`

**Say:** "Commit hooks run even if you skipped `pre-commit install`. dbt structural checks run after
a full build."

### B3. Branch → PR (gloss, ~30 sec)

**Say:** "Standard flow — branch, push, open PR; both workflows above run on the PR. Details:
`docs/github.md`."

### B4. Slim CI in Actions (discuss, ~1 min)

**Say:** "Part C7 demos **Slim CI** locally (`--defer --state`). Here we run a **full** build every
PR. Production pattern: upload manifest artifact from `main`, matrix per domain, PR job runs
`state:modified+ --defer` only — faster, same trust model. Backlog: `docs/remaining-work.md`
Phase 4."

**Show:** `.github/workflows/ci.yml` line 19 vs C7 commands — contrast full build vs deferred build.

---

## Part C — dbt live demo (~20–25 min)

### C1. Framing (1 min)

**Say:** Mono-repo, **3 dbt projects** on **DuckDB**, shared jaffle-shop data (~62k orders).
Goal: full dbt feature surface, not just `dbt run`. Naming: `docs/conventions.md`.

---

### C2. DAG: stage → intermediate → mart (3 min)

**Say:** Layered models, mixed materializations.

```bash
dbt ls --select staging
dbt ls --select marts
dbt build --select finance_fct_order_revenue+
```

**Show:** `models/` tree, `dbt_project.yml` `models:` block (+schema layers in finance).

---

### C3. Incremental models (3 min)

```bash
dbt run --select finance_fct_order_revenue
dbt run --select finance_fct_order_revenue --full-refresh
```

**Show:** `models/marts/finance_fct_order_revenue.sql` — `is_incremental()`, `unique_key`,
`incremental_strategy='delete+insert'`, `on_schema_change`. Mechanics: `docs/dbt-feature-guide.md`.

---

### C4. Tests — built-in, custom, singular, unit (4 min)

```bash
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select test_type:unit
```

**Show custom generics** (more than `not_negative`):
- `tests/generic/not_empty_string.sql`
- `tests/generic/accepted_range.sql` (parametrized)

**Show:** `warn_high_margin_orders` — `severity: warn` + `store_failures: true`.

```bash
dbt test --select warn_high_margin_orders
# select * from dev_dbt_test__audit.warn_high_margin_orders;
```

**Discuss — observability beyond dbt tests (~30 sec):**

**Say:** "dbt tests catch logic at build time. At scale teams add **observability** products
(Elementary, Monte Carlo, etc.) for anomaly detection, lineage alerts, and incident workflows.
This repo stops at native dbt tests + `store_failures` — enough for the demo."

---

### C5. Macros + run-operation (2 min)

```bash
dbt run-operation audit_relations
```

**Show:** `macros/audit_relations.sql` (`run_query()`), `macros/cents_to_dollars.sql`,
`macros/generate_schema_name.sql`.

---

### C6. Sources, freshness, snapshots, seeds (2 min)

```bash
dbt source freshness
dbt snapshot
```

**Say:** SCD2 snapshot (`finance_snapshot_products`), source freshness on `raw_orders`.

**Discuss — governance (~30 sec):**

**Say:** "Enterprise warehouses add **grants**, **RLS**, and model **contracts**. DuckDB demo
skips those — documented as N/A in `docs/remaining-work.md`. Same dbt project structure ports
to Snowflake/BigQuery with warehouse-native permissions."

---

### C7. `--defer` + `--state` + `dev_schema` (3 min) — headline

**Prerequisite:** prod fully built (pre-warm).

```bash
git checkout main
dbt compile --target-path /tmp/dbt --target prod

git checkout <your-branch>
printf '\n-- demo change\n' >> models/marts/finance_fct_daily_revenue.sql

dbt build --select state:modified+ --defer --state /tmp/dbt \
  --vars '{"dev_schema":"dev"}' --target prod

git checkout -- models/marts/finance_fct_daily_revenue.sql
```

**Say:** On `main`, capture prod manifest to `/tmp/dbt`. On your branch, build only
`state:modified+`; defer unchanged refs to prod; `dev_schema` flattens your builds into one
sandbox schema. Both steps use `--target prod` so DuckDB catalog names match (`prod.duckdb` →
catalog `prod`). Detail: `docs/dbt-feature-guide.md`.

**Say:** "This is the local proof for **Slim CI** (see B4). In Actions you'd persist this manifest
from `main` and run the same selector on every PR."

---

### C8. Docs + exposure (2 min)

```bash
./dbt_docs.sh mart_finance    # second terminal (repo root) — serves :8011
```

**Show:** DAG graph, `{% docs %}` blocks, `revenue_dashboard` exposure.

---

### C9. Packages + multi-project (1 min)

**Say:** `dbt_utils` via `packages.yml` / `dbt deps`; same patterns in all three domains.

```bash
cd ../mart_marketing && dbt build
cd ../mart_operations && dbt build
```

**Discuss — feature sandbox (~30 sec):**

**Say:** "Finance carries the richest feature set (snapshots, exposures, unit tests). Backlog:
`mart_showcase/` for one worked example of each dbt config, then spread patterns to all
domains — `docs/remaining-work.md` Phase 2."

---

## Part F — Production & platform path (~5 min)

**Say:** "The demo is intentionally local and small. This table is what we'd add or swap in a
real platform — same repo shape, different runtime."

| Topic | In this demo | Typical production |
|-------|--------------|-------------------|
| **Runtime** | `uv` + `./setup.sh` | Docker / devcontainer with same `requirements.json` |
| **Infrastructure** | None (local files) | **Terraform** / cloud IaC — warehouse, IAM, buckets |
| **Warehouse** | DuckDB file per env | Snowflake, BigQuery, Postgres, etc. |
| **Environments** | dev + prod built in setup; **staging** in profile but not demo'd | dev → staging → prod promote; CI secrets per target |
| **Ingestion** | `load_raw.py` + vendored CSVs | Fivetran, Airbyte, streaming, API loads |
| **CI — PR checks** | `pre-commit.yml` + full `ci.yml` build | Same, plus **Slim CI** manifest defer (B4, C7) |
| **CI — schedule** | Manual / `dbt_build_all.sh` | Cron Action, Airflow, Dagster, dbt Cloud |
| **Observability** | dbt tests + `store_failures` | Elementary, Monte Carlo, custom alerting |
| **Governance** | Descriptions + tests enforced in CI | Grants, RLS, model contracts |
| **Feature lab** | Finance-heavy | `mart_showcase/` then roll out to domains |

**Show:** `docs/architecture.md` (env table, DuckDB single-writer note), `docs/remaining-work.md`.

**Say:** "DuckDB keeps the demo free and offline. The dbt projects, tests, and CI patterns transfer
directly — only the profile target and orchestration layer change."

---

## Part D — AI workflow (~10 min)

**Say:** "The repo is structured so AI agents need minimal prompting — durable context lives
in files, not chat history."

| Layer | File | Purpose |
|---|---|---|
| Source of truth | `AGENTS.md` | Stack, commands, autonomy matrix, doc index |
| Auto-loaded rules | `.cursor/rules/*.mdc` | Cursor reads every chat (`core`, `dbt`, `python`) |
| Claude entry | `CLAUDE.md` | Imports `AGENTS.md`; no MCP in this repo |
| Session handoff | `docs/STATUS.md` | Read first, update last — resume in a fresh chat |
| Token patterns | `docs/ai-practices.md` | How to work lean (both Cursor and Claude) |
| Backlog | `docs/remaining-work.md` | What to pick up next |

**Token-efficiency rules (say these out loud):**

- **`@`-reference files** — don't paste whole files or logs into chat
- **Scoped asks** — "fix X in `finance_fct_order_revenue`" not "review everything"
- **Fresh chat when stale** — resume via `docs/STATUS.md`, not megabytes of history
- **Don't re-explain the stack** — `AGENTS.md` + rules already load it
- **Subagents for broad exploration** — parent synthesizes; main thread stays small
- **Human commits/pushes only** — AI may stage + propose a message, never `git commit`/`push`

**Cursor vs Claude Code:**

| | Cursor | Claude Code |
|---|---|---|
| Config | `.cursor/rules/*.mdc` | `CLAUDE.md` → `AGENTS.md` |
| File refs | `@path` in chat | path in prompt |
| MCP | optional (not used here) | **disabled** — terminal + files only |
| Skills | user-level `~/.cursor/skills-cursor/` | N/A |

**Skills (Cursor):** not vendored in this repo — they live in your Cursor user directory
(`~/.cursor/skills-cursor/<name>/SKILL.md`). The agent reads a skill when the task matches
(e.g. create-rule, create-skill, babysit PR). You can add repo-specific skills there or
author new ones with the create-skill skill.

**Demo prompt for a new chat:**

> Read `docs/STATUS.md` and continue.

---

## Part E — Wrap (~3 min)

**Recap:** reproducible env (uv = container contract) → CI mirrors local → full dbt surface →
production path (Part F) → AI config keeps tokens low. Backlog: Slim CI in Actions, GitHub Pages
docs, `_showcase/` — `docs/remaining-work.md`.

---

## Quick reference — all commands in order

```bash
# Pre-warm
. ./setup.sh
./scripts/bootstrap.sh

# Part C — dbt
dbt ls --select staging
dbt build --select finance_fct_order_revenue+
dbt run --select finance_fct_order_revenue --full-refresh
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select test_type:unit
dbt run-operation audit_relations
dbt source freshness
dbt snapshot
git checkout main && dbt compile --target-path /tmp/dbt --target prod
git checkout <your-branch>
printf '\n-- demo change\n' >> models/marts/finance_fct_daily_revenue.sql
dbt build --select state:modified+ --defer --state /tmp/dbt --vars '{"dev_schema":"dev"}' --target prod
git checkout -- models/marts/finance_fct_daily_revenue.sql
./dbt_docs.sh mart_finance
```
