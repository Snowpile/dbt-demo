# dbt_demo — meeting agenda (step-by-step runbook)

~45–50 min. Each step has **say** (the point) and **run** / **show** (what to do).
Deep-dives: `docs/dbt-feature-guide.md` (dbt mechanics), `docs/ai-practices.md` (AI patterns).

> **macOS / Linux / Windows (Git Bash / WSL).** On Windows use Git Bash for `./*.sh`.

---

## Pre-warm (before the room, ~5 min)

**Say:** "One command gives us a reproducible Python env — same locally and in CI."

```bash
./setup.sh    # venv, config, seed scan, dev + prod builds → lands in projects/finance
```

Open a **second terminal** for `./dbt_docs.sh finance` (Part C8 — blocks on port 8011).

---

## Part A — Reproducible environment (~5 min)

**Say:** "We don't ship a Docker image in this demo — **`uv` + `./setup.sh` is the runtime contract**.
CI runs the exact same script; in production you'd wrap this in a container with the same
`requirements.json`."

| Piece | Role |
|---|---|
| `requirements.json` + `setup.py` | Pinned deps (`dbt-duckdb`, `duckdb`); dev extras (`ruff`, `pre-commit`) |
| `./setup.sh` | `uv venv` → install → copy `.env` / `profiles.yml` → `pre-commit install` → scan seeds → `dbt build` dev + prod → project shell |
| `scripts/env.sh` | Exports `DBT_PROFILES_DIR`, DuckDB paths, venv bin (`.venv/bin` or `.venv/Scripts`) |
| `.env` / `profiles.yml` | Local paths (gitignored); one DuckDB **file per env** (dev / staging / prod) |

**Show:** `requirements.json`, `setup.sh`, `profiles.yml.example`.

**Say:** "Raw CSVs are integrity-checked (`scan_downloads.sh`: SHA-256, MIME, UTF-8) then loaded
into DuckDB schema `raw` (`load_raw.sh` → `load_raw.py`). dbt never reads CSVs directly."

Data flow (see `docs/architecture.md` for detail):

```
data/seeds/*.csv  →  load_raw.py  →  raw.*  →  projects/<domain>/models  →  stg → int → fct/dim
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

**`ci.yml`** — same pipeline as local pre-warm / full bootstrap:

1. `actions/checkout`
2. `astral-sh/setup-uv` (cached)
3. `./setup.sh` — scan seeds + load raw + `dbt build` dev + prod
4. **dbt-checkpoint** manual-stage hooks (need manifests from step 3):
   `check-script-has-no-table-name`, `check-model-has-description`,
   `check-model-has-tests`

**Say:** "Commit hooks run even if you skipped `pre-commit install`. dbt structural checks run after
a full build."

**Branch + PR workflow** (one-time remote setup: `docs/github.md`):

```bash
git checkout -b feat/my-change
# ... work; human commits when ready ...
git push -u origin feat/my-change
gh pr create --title "..." --body "..."
```

**Say:** "Part C step 7 shows **Slim CI** locally (`--defer --state`). Wiring that into GitHub
Actions (manifest artifact from `main`, matrix per domain) is Phase 4 backlog — intentionally
not implemented yet."

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

---

### C8. Docs + exposure (2 min)

```bash
cd .. && ./dbt_docs.sh finance    # second terminal — serves :8011
```

**Show:** DAG graph, `{% docs %}` blocks, `revenue_dashboard` exposure.

---

### C9. Packages + multi-project (1 min)

**Say:** `dbt_utils` via `packages.yml` / `dbt deps`; same patterns in all three domains.

```bash
cd projects/marketing && dbt build
cd ../operations && dbt build
```

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
AI config keeps tokens low. Backlog: Slim CI in Actions, SQLFluff in CI, spread finance-only
features to other domains — `docs/remaining-work.md`.

---

## Quick reference — all commands in order

```bash
# Pre-warm
./setup.sh

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
cd .. && ./dbt_docs.sh finance
```
