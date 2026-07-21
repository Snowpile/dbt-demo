# Defer, state selectors, and slim builds

**Slim CI:** build only what changed vs a baseline `manifest.json` (usually `main` /
prod); resolve other `ref()`s with `--defer --state`.

Day-of demo: `docs/demo-agenda.md` §C9. Scripts below wrap the same flags.

## Environments (prod + QA only)

This repo uses **one warehouse file** (`data/prod.duckdb`) and two dbt targets:

| Target | Role | Typical use |
|--------|------|-------------|
| **prod** | Canonical marts + CI baseline on `main` | `bootstrap.sh`, `publish_state.sh`, full builds |
| **qa** | Same file as prod; semantic “validation” target | Default in `.env`; alias for ad-hoc work |

There is **no separate dev or staging DuckDB**. Local branch and PR work use **`--target prod`** (catalog must match the state manifest) plus:

- `--defer --state …` — unselected refs resolve to prod relations
- `--vars '{"dev_schema":"dev"}'` — changed nodes land in a flat sandbox schema

`dev_schema` is the dbt var name (community convention); it is the **sandbox**, not a third environment.

```
main bootstrap → prod marts in prod.duckdb → publish dbt-state
PR / branch    → slim build on prod.duckdb + defer + dev_schema sandbox
```

## Prerequisites

1. Baseline warehouse already built for the domain (prod locally, or CI artifact).
2. Capture and slim use the **same** `--target` so DuckDB catalog names match
   (`prod.duckdb` → catalog `prod`).

## Scripts

| Script | Role |
|--------|------|
| `./scripts/pull_state.sh [mart_*]` | `dbt compile --target prod --target-path state/<project>/` |
| `./scripts/publish_state.sh` | `pull_state` for all three domains |
| `./scripts/slim_build.sh [mart_*] [selector]` | `dbt build --select … --defer --state state/<project>/` |
| `./scripts/slim_build_all.sh [selector]` | Slim-build every domain that has a manifest |
| `./scripts/clone_state.sh [mart_*] [selector]` | Optional wrapper around `dbt clone` (see below) |

`state/` is gitignored (see `.gitignore`).

### Minimal local loop (finance)

```bash
. ./setup.sh
DBT_TARGET=prod ./scripts/dbt_build_all.sh   # once / when prod is stale
./scripts/publish_state.sh                   # or: ./scripts/pull_state.sh mart_finance

# on a branch with model edits:
./scripts/slim_build.sh mart_finance
# equivalent selector demos:
./scripts/slim_build.sh mart_finance 'state:modified'
./scripts/slim_build.sh mart_finance 'state:new'
./scripts/slim_build.sh mart_finance '+state:modified+'
```

Manual (matches agenda `/tmp/dbt`):

```bash
cd mart_finance
dbt compile --target-path /tmp/dbt --target prod   # or omit --target after a live build
dbt build --select state:modified+ --defer --state /tmp/dbt \
  --vars '{"dev_schema":"dev"}' --target prod
```

## Flags

| Flag / selector | Role |
|-----------------|------|
| `state:modified` | Nodes whose definition changed vs state manifest |
| `state:modified+` | Modified **plus downstream** (usual slim CI select) |
| `state:new` / `state:old` | Present only in project / only in state |
| `+state:modified+` | Modified + upstream + downstream |
| `--defer` | Unselected `ref()`s resolve to relations in the state manifest |
| `--state <dir>` | Directory containing baseline `manifest.json` |
| `--defer-state <dir>` | Optional: separate dir for defer vs state comparison |
| `--vars '{"dev_schema":"dev"}'` | Flatten built nodes into one sandbox schema |
| `--favor-state` | Prefer state relations even if a local relation exists |

## Env vars

| Variable | Effect |
|----------|--------|
| `DBT_STATE` | Default directory for `--state` (dbt built-in) |
| `DBT_DEFER_STATE` | Default for `--defer-state` (dbt built-in) |
| `DBT_STATE_ROOT` | Parent of per-project dirs for **these scripts** (default `<repo>/state`) |
| `DBT_STATE_TARGET` | Baseline target for pull/slim/clone scripts (default `prod`) |
| `DBT_DEV_SCHEMA` | Value passed as `dev_schema` var (default `dev`) |

Example:

```bash
export DBT_STATE="$PWD/state/mart_finance"
export DBT_DEFER_STATE="$DBT_STATE"
cd mart_finance
dbt build --select state:modified+ --defer --vars '{"dev_schema":"dev"}' --target prod
```

## `dbt clone` (optional)

Same `--state` family as defer, but **creates** objects (zero-copy clone where supported; on DuckDB, pointer views) instead of resolving `ref()`s at compile time. This demo and Slim CI rely on **`--defer`**, not clone.

- Docs: [About dbt clone](https://docs.getdbt.com/reference/commands/clone)
- Compare approaches: [To defer or to clone](https://docs.getdbt.com/blog/to-defer-or-to-clone)
- Local wrapper (if needed): `./scripts/clone_state.sh mart_finance`

## CI (GitHub Actions)

| Event | Job | Behavior |
|-------|-----|----------|
| Push to `main` | `publish-state` | Full `bootstrap.sh` → dbt-checkpoint → `publish_state.sh` → upload artifact **`dbt-state`** (`state/*/manifest.json` + `data/prod.duckdb`) |
| Pull request | `slim-pr` | Download latest successful main **`dbt-state`** → `load_raw.sh prod` → `slim_build_all.sh state:modified+` → compile + checkpoint |

If no main artifact exists yet (first clone / cold start), the PR job **falls back** to a full bootstrap.

DuckDB has no shared cloud warehouse, so the artifact includes **`prod.duckdb`** so deferred `ref()`s resolve to real relations. On Snowflake/BQ you'd persist manifests only and point at the live prod database.

## Related

- `macros/generate_schema_name.sql` + `vars.dev_schema` — sandbox naming
- `docs/dbt-feature-guide.md` — short flag table
- `docs/demo-agenda.md` §B4 / §C9 — talk track
