# dbt_demo — meeting agenda (step-by-step runbook)

~50–55 min. Each step has **say** (the point) and **run** / **show** (what to do).
Deep-dives: `docs/dbt-feature-guide.md` (dbt mechanics), `docs/ai-practices.md` (AI patterns).

> **macOS / Linux / Windows (Git Bash / WSL).** On Windows use Git Bash for `./*.sh`.

---

## Pre-warm (before the room, ~2 min)

**Say:** "One step sets up the Python environment — dbt runs live in Part C, one command at a time."

```bash
. ./setup.sh    # venv, config, dbt --version (~1 min)
```

**Optional (off-line, for C7 defer demo only):** run `./scripts/bootstrap.sh` or at least a prod build so
`--defer --state` has a manifest to point at. **Do not** run full bootstrap on screen in the room.

Open a **second terminal** when you reach Part C8: `./dbt_docs.sh mart_finance` (port 8011).

---

## Part A — Reproducible environment (~5 min)

**Say:** "We don't ship a Docker image in this demo — **`uv` + `./setup.sh`** installs the runtime.
**`./scripts/bootstrap.sh`** is what **CI** runs (scan → load → full build); in **Part C** we run the
same steps **one command at a time** so you can see each piece. In production you'd wrap the same
`requirements.json` in a container."

| Piece | Role |
|---|---|
| `requirements.json` + `setup.py` | Pinned deps (`dbt-duckdb`, `duckdb`); dev extras (`ruff`, `pre-commit`) |
| `./setup.sh` | `uv venv` → install → copy `.env` / `profiles.yml` → `pre-commit install` → `dbt --version` |
| `./scripts/bootstrap.sh` | **CI** (and optional off-line C7 pre-warm): `scan_downloads` → `load_raw` → `dbt build` dev + prod |
| `scripts/load_raw.sh` | Load seeds → DuckDB `raw.*` — run in **Part C** before first dbt build |
| `scripts/env.sh` | Exports `DBT_PROFILES_DIR`, DuckDB paths, venv bin (`.venv/bin` or `.venv/Scripts`) |
| `.env` / `profiles.yml` | Local paths (gitignored); one DuckDB **file per env** (dev / staging / prod) |

**Show:** `profiles.yml.example` — three targets; **CI** builds dev + prod via bootstrap; **staging**
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

Data flow (see `AGENTS.md` / `README.md` for architecture):

```
data/seeds/*.csv  →  load_raw.py  →  raw.*  →  mart_<domain>/models  →  stg → int → fct/dim
```

---

## Part B — CI/CD & GitHub (~5 min)

**Show:** `.github/workflows/pre-commit.yml` then `.github/workflows/ci.yml`

**Say:** "Two workflows on every PR / push to `main`:"

**`pre-commit.yml`** — same hooks as local `git commit` (for devs without pre-commit installed):

1. `actions/checkout` (`fetch-depth: 0` so changed-files works on PRs)
2. `tj-actions/changed-files` — list files in the PR / push
3. `pre-commit/action` — **no explicit `run:` in our YAML**; the action installs pre-commit and
   executes (equivalent to):
   `pre-commit run --show-diff-on-failure --color=always --files <changed files>`
   Uses the runner's built-in Python + pip (not `uv` / not our `.venv`). Each hook in
   `.pre-commit-config.yaml` gets its own isolated env. Skips if no files changed.

**Say (hooks):** "Two linters in that hook set: **Ruff** for Python (`scripts/`, `setup.py` —
`ruff.toml`), **SQLFluff** for dbt models (`mart_*/models/**/*.sql` — `.sqlfluff`). Both run on
local commit and again in this workflow on the PR diff. Dirty Python or SQL fails the job."

**Optional show:** `.pre-commit-config.yaml` Ruff block then SQLFluff block (`sqlfluff-lint` /
`sqlfluff-format`).

**`ci.yml`** — environment + warehouse bootstrap (full build — not shown live in the demo room):

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

**Say:** "Standard flow — branch, push, open PR; both CI workflows run on the PR. Details:
`AGENTS.md` (GitHub / PR workflow)."

### B4. Slim CI in Actions (discuss, ~1 min)

**Say:** "Part C7 demos **Slim CI** locally (`--defer --state`). Here we run a **full** build every
PR. Production pattern: upload manifest artifact from `main`, matrix per domain, PR job runs
`state:modified+ --defer` only — faster, same trust model. Backlog: `docs/remaining-work.md`
Phase 4."

**Show:** `.github/workflows/ci.yml` line 19 vs C7 commands — contrast full build vs deferred build.

---

## Part C — dbt live demo (~20–25 min)

**Before C2** (repo root, then project dir):

```bash
./scripts/load_raw.sh          # from repo root — CSV → raw.*
cd mart_finance
```

Run each dbt command below **one at a time** (do not run `./scripts/bootstrap.sh` on screen).

### C1. Framing (1 min)

**Say:** Mono-repo, **3 dbt projects** on **DuckDB**, shared jaffle-shop data (~62k orders).
Goal: full dbt feature surface, not just `dbt run`. Naming: `docs/conventions.md`.

---

### C2. DAG: stage → intermediate → mart (3 min)

**Say:** Layered models, mixed materializations. Prefer building **up to** marts, testing, then marts.

```bash
dbt ls --select staging
dbt ls --select marts
# Pre-mart gate (verify staging + intermediate BEFORE marts):
dbt build --select staging intermediate
dbt test  --select staging intermediate
dbt build --select marts
# Or a single mart + upstream:
dbt build --select +finance_fct_order_revenue
```

**Show:** `models/` tree, `dbt_project.yml` (`+tags`, `+meta`, `+docs.node_color`, `+persist_docs`,
`+schema`, `vars.dev_schema`, `on-run-start`/`on-run-end`). Contrast project vs `schema.yml`
`config:` vs model `config()` (alias/hooks on `finance_fct_order_revenue`).

---

### C3. Incremental models (4 min)

```bash
dbt run --select finance_int_orders_delta finance_int_order_items_delta finance_int_changed_order_ids finance_fct_order_revenue
dbt run --select finance_fct_order_revenue --full-refresh
```

**Show:**

1. Two incremental **parents**: `finance_int_orders_delta`, `finance_int_order_items_delta`
2. **Changed-ID union**: `finance_int_changed_order_ids` (unions keys from both parents)
3. **Child**: `finance_fct_order_revenue` — on incremental runs joins to that ID set
4. `is_incremental()`, `unique_key`, `delete+insert`, `on_schema_change`

**Say:** "When a child incremental depends on more than one incremental parent, materialize a
union of IDs first so the child only rebuilds keys that need work."

**Also show hooks on the child:** `pre_hook` retention `DELETE` + audit insert;
`post_hook` `UPDATE loaded_at` + audit insert → `audit.dbt_model_hooks`.

Mechanics: `docs/dbt-feature-guide.md`.

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

**Say:** SCD2 snapshot (`finance_snapshot_products`), source freshness on `raw_orders`
(**all three projects** declare freshness).

**Discuss — governance (~30 sec):**

**Say:** "Enterprise warehouses add **grants**, **RLS**, and model **contracts**. DuckDB demo
skips those — called out as N/A in `dbt_project.yml` comments / Phase 2 backlog. Same project
structure ports to Snowflake/BigQuery with warehouse-native permissions."

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

**Show:** DAG graph, shared `{% docs %}` in `models/docs/*.md` (e.g. `order_id` reused across
tables), `revenue_dashboard` exposure.

---

### C9. Packages + multi-project (1 min)

**Say:** `dbt_utils` via `packages.yml` / `dbt deps`; same patterns in all three domains
(`dev_schema`, freshness, shared docs).

```bash
cd ../mart_marketing && dbt build
cd ../mart_operations && dbt build
```

**Discuss — orchestration options (~30 sec):**

**Say:** "Two non-Airflow stubs: `.github/workflows/orchestrate.yml` (pseudo-runnable) and
`prefect/README.md` (docs-only). CI remains the PR gate; orchestration is how you'd schedule
the same scripts in production."

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
| **CI — schedule** | `orchestrate.yml` stub + `prefect/` stub | Cron Action, Prefect, Dagster, dbt Cloud (not Airflow-first) |
| **Observability** | dbt tests + `store_failures` | Elementary, Monte Carlo, custom alerting |
| **Governance** | Descriptions + tests enforced in CI | Grants, RLS, model contracts |
| **Feature lab** | Finance-heavy | `mart_showcase/` then roll out to domains |

**Show:** `README.md` / `AGENTS.md` (env table, DuckDB single-writer), `DEMO_CHECKLIST.md` Pre-review cleanup / Phase 2+.

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
# Pre-warm (repo root, before the room)
. ./setup.sh

# Optional off-line (C7 defer manifest)
./scripts/bootstrap.sh

# Part C — from repo root, then mart_finance
./scripts/load_raw.sh
cd mart_finance
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
