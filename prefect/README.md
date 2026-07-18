# Prefect orchestration stub

**Status:** documentation-only stub (pre-review cleanup #15). No runnable Prefect flow is
checked in — this is the second **non-Airflow** orchestration option alongside GitHub Actions.

## Why it is here

Enterprise teams often pick either:

1. **GitHub Actions** — schedule / `workflow_dispatch` calling the same scripts CI uses
2. **Prefect** (or similar) — Python flows that shell out to `./scripts/bootstrap.sh` or
   per-domain `dbt build`

Airflow is intentionally **not** the demo default.

## Intended shape (when implemented)

```text
prefect/
  README.md          ← you are here
  flows/
    dbt_pipeline.py  ← @flow: scan → load_raw → dbt_build_all (not committed yet)
  deployments/       ← work pools / schedules (later)
```

Pseudo-flow:

```python
# NOT wired — illustrative only
from prefect import flow, task

@task
def bootstrap():
    # subprocess: ./scripts/bootstrap.sh
    ...

@flow(name="dbt_demo_daily")
def dbt_demo_daily():
    bootstrap()
```

## Local alternative today

```bash
. ./setup.sh
./scripts/bootstrap.sh
```

## Related

- GitHub Actions orchestration stub: `.github/workflows/orchestrate.yml`
- CI (lint + full build on PR): `.github/workflows/ci.yml`, `pre-commit.yml`
- Demo Part F: `docs/demo-agenda.md`
