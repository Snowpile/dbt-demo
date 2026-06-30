# benderik — dbt demo agenda (step-by-step runbook)

A sequential script for live-demoing this repo. ~20–25 min. Each step has **say**
(the point) and **run** (the exact command). Feature deep-dives live in
`docs/dbt-feature-guide.md`; this file is the *order of operations*.

> Works on **macOS, Linux, and Windows (Git Bash / WSL)**. On Windows use Git Bash
> so the `./*.sh` scripts run; everything else is identical.

---

## 0. Before the room joins (one-time, ~3 min)

**Say:** "Single command sets up a reproducible Python env (uv), profiles, and seeds."

```bash
./setup.sh                              # .venv + .env + profiles.yml (+ hooks if a git repo)
source .venv/bin/activate               # Windows Git Bash: source .venv/Scripts/activate
source scripts/env.sh                   # exports DBT_PROFILES_DIR, DuckDB paths, etc.
uv run dbt --version                    # sanity check
```

**Pre-warm the warehouse so the live build is fast:**

```bash
./scripts/dbt_build_all.sh              # green: finance 61/1 warn, marketing 54, operations 52
```

Leave a second terminal open in `projects/finance` for the live commands:

```bash
cd projects/finance
```

---

## 1. Framing (1 min, no commands)

**Say:**
- Mono-repo, **3 dbt projects** (`finance`, `marketing`, `operations`) on **DuckDB**, one file per env (dev / staging / prod).
- Same shared seed data (`dbt-labs/jaffle-shop`, ~62k orders) flowing through stage → intermediate → mart.
- Goal of the demo: show the full dbt feature surface, not just `dbt run`.

---

## 2. The DAG: stage → intermediate → mart (3 min)

**Say:** "Layered models, mixed materializations — `view` for staging, `ephemeral`/`view`/`table` for intermediate, `table` + `incremental` for marts."

```bash
dbt ls --select staging                 # the bronze views
dbt ls --select marts                   # the gold tables
dbt build --select finance_fct_order_revenue+   # build a slice + its children
```

Point at `models/` folder structure and `dbt_project.yml` `models:` config block.

---

## 3. Incremental models (3 min)

**Say:** "Marts are incremental — cost scales with *new* rows, not full history."

```bash
dbt run --select finance_fct_order_revenue                 # incremental: no-op if no new rows
dbt run --select finance_fct_order_revenue --full-refresh  # rebuild from scratch
```

Open `models/marts/finance_fct_order_revenue.sql`, point at the
`{% if is_incremental() %}` filter, `unique_key`, `incremental_strategy='delete+insert'`,
`on_schema_change`. (Full explainer: `docs/dbt-feature-guide.md`.)

---

## 4. Tests — built-in, custom, singular, unit (4 min)

**Say:** "Four kinds of tests, all in one project."

```bash
dbt test --select test_type:generic     # unique, not_null, accepted_values, relationships,
                                         # dbt_utils.*, AND our custom generics
dbt test --select test_type:singular     # assert_order_revenue_reconciles, assert_no_future_orders
dbt test --select test_type:unit         # test_stg_orders_cents_to_dollars (given/expect)
```

**Custom generic tests** (more than just "not negative") — open:
- `tests/generic/not_negative.sql`
- `tests/generic/not_empty_string.sql`     (null / blank text)
- `tests/generic/accepted_range.sql`       (parametrized: `min_value`, `max_value`, `inclusive`)

**Severity + stored failures:** `warn_high_margin_orders` warns instead of failing the
build, and `store_failures: true` keeps the rows for inspection:

```bash
dbt test --select warn_high_margin_orders
# then query the audit table (dev schema shown):
#   select * from dev_dbt_test__audit.warn_high_margin_orders;
```

---

## 5. Macros + run-operation (2 min)

**Say:** "Macros: a shared `cents_to_dollars`, an env-aware `generate_schema_name`, and an
operational macro you invoke directly."

```bash
dbt run-operation audit_relations        # live row counts per mart via run_query()
```

Open `macros/audit_relations.sql` (uses `run_query()` / `execute`) and
`macros/cents_to_dollars.sql` (used in staging).

---

## 6. Sources, freshness, snapshots, seeds (2 min)

```bash
dbt source freshness                     # loaded_at_field + thresholds on raw_orders
dbt snapshot                             # finance_snapshot_products (SCD2, check strategy)
```

**Say:** seeds are vendored CSVs, integrity-checked before load (`scripts/scan_downloads.sh`:
SHA-256 pins, MIME, null-byte + UTF-8 CSV parse).

---

## 7. `--defer` + `--state` with the `dev_schema` var (3 min) — the headline

**Say:** "This is the backbone of Slim CI: build only what changed, defer everything else
to prod, all flattened into one sandbox schema via a project var."

```bash
# 1. Capture a prod manifest once = the "state" to defer against.
dbt compile --target prod
mkdir -p ../../state/finance
cp target/manifest.json ../../state/finance/manifest.json

# 2. Build ONLY changed models + children, deferring unchanged refs to prod,
#    flattened into a single `dev` schema via the dev_schema var.
dbt build --select state:modified+ --defer --state ../../state/finance --favor-state \
  --vars '{"dev_schema":"dev"}'
```

Open `macros/generate_schema_name.sql` — show how the `dev_schema` var short-circuits
the env-aware layered schemas (`dev_source_data` / `dev_transform` / `dev_mart`) into one
flat `dev` sandbox. (Deep-dive: `docs/dbt-feature-guide.md`.)

---

## 8. Docs site + exposure (2 min)

```bash
cd ..                                    # back to repo root
./dbt_docs.sh finance                    # build + generate + serve on :8011
```

Open the browser: show the DAG graph, `{% docs %}` blocks (`models/docs.md`), column
descriptions, and the **`revenue_dashboard` exposure** as a downstream consumer.

---

## 9. Packages + multi-project (1 min)

**Say:** "`dbt_utils` pulled via `packages.yml` / `dbt deps`; used for
`expression_is_true` and `unique_combination_of_columns` tests. The same patterns
repeat across all three domains."

```bash
cd ../marketing && dbt build             # parity across projects
cd ../operations && dbt build
```

---

## 10. Wrap (1 min, no commands)

**Recap the surface shown:** layered DAG, all materializations, incremental,
4 test types + custom/parametrized generics + severity/store_failures, macros +
run-operation, sources/freshness/snapshots/seeds, `--defer --state` Slim-CI pattern,
docs + exposure, dbt_utils, 3-project mono-repo. CI wiring is intentionally theoretical
(see `docs/remaining-work.md` Phase 4).

---

## Quick reference — all demo commands in order

```bash
./setup.sh && source .venv/bin/activate && source scripts/env.sh
./scripts/dbt_build_all.sh
cd projects/finance
dbt ls --select staging
dbt build --select finance_fct_order_revenue+
dbt run --select finance_fct_order_revenue --full-refresh
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select test_type:unit
dbt run-operation audit_relations
dbt source freshness
dbt snapshot
dbt compile --target prod && mkdir -p ../../state/finance && cp target/manifest.json ../../state/finance/manifest.json
dbt build --select state:modified+ --defer --state ../../state/finance --favor-state --vars '{"dev_schema":"dev"}'
cd .. && ./dbt_docs.sh finance
```
