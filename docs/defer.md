# Defer, state selectors, and slim builds

Local proof of **Slim CI**: build only what changed on your branch; resolve other `ref()`s
from a baseline `manifest.json` (usually prod / `main`).

Day-of demo commands: `docs/demo-agenda.md` §C7. Scripts below wrap the same flags.

## Prerequisites

1. Prod (or staging) warehouse already built for the domain:
   `DBT_TARGET=prod ./scripts/dbt_build_all.sh` (or build one project).
2. Both capture and slim steps use the **same** `--target` so DuckDB catalog names match
   (`prod.duckdb` → catalog `prod`).

## Scripts

| Script | Role |
|--------|------|
| `./scripts/pull_state.sh [mart_*]` | `dbt compile --target prod --target-path state/<project>/` |
| `./scripts/slim_build.sh [mart_*] [selector]` | `dbt build --select … --defer --state state/<project>/` |
| `./scripts/clone_state.sh [mart_*] [selector]` | `dbt clone --state …` into the `dev_schema` sandbox |

`state/` is gitignored (see `.gitignore`).

### Minimal local loop (finance)

```bash
. ./setup.sh
DBT_TARGET=prod ./scripts/dbt_build_all.sh   # once / when prod is stale
./scripts/pull_state.sh mart_finance

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
dbt compile --target-path /tmp/dbt --target prod
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

## `dbt clone`

After `pull_state.sh`, clone materializes pointers (on DuckDB: views) into the sandbox schema
so deferred parents exist without a full rebuild:

```bash
./scripts/clone_state.sh mart_finance
# or only staging:
./scripts/clone_state.sh mart_finance 'path:models/staging'
```

Then slim-build only the models you edited.

## CI

- **PR gate** stays a full `./scripts/bootstrap.sh` (`.github/workflows/ci.yml`) — trust model for the demo.
- **Slim CI pattern** (optional): `.github/workflows/slim-ci.yml` (`workflow_dispatch`) captures state after a prod build and runs `state:modified+ --defer`. Wire artifact upload from `main` when you want PRs to download a real `main` manifest instead of capturing in-job.

## Related

- `macros/generate_schema_name.sql` + `vars.dev_schema` — sandbox naming
- `docs/dbt-feature-guide.md` — short flag table
- `DEMO_CHECKLIST.md` Phase 2 — “Slim CI in Actions” as a future PR-gate swap
