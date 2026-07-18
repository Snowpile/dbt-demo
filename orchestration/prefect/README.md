# Prefect orchestration stub

**Status:** documentation-only stub. No runnable Prefect flow is checked in.

## Docs

- [Prefect documentation](https://docs.prefect.io/)
- [Self-hosting Prefect](https://docs.prefect.io/v3/manage/self-host) (server, workers, work pools)
- [Prefect Cloud](https://docs.prefect.io/v3/manage/cloud) (hosted alternative)

## Why it is here

One of three orchestration options in this demo (alongside GitHub Actions and Airflow):

1. **GitHub Actions** — `.github/workflows/orchestrate.yml`
2. **Prefect** — Python flows (Cloud or self-host) that shell `./scripts/bootstrap.sh` / `dbt build`
3. **Airflow** — `airflow/` stub (industry-standard DAG scheduler)

## Dependencies (not installed by default)

`./setup.sh` only installs `.[dev]`. Prefect packages live under the `prefect` extra in
`requirements.json` (treated as commented-out until you opt in):

```bash
# uv pip install -e '.[prefect]'
# # which pulls: prefect>=3.0,<4
```

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

- GitHub Actions: `.github/workflows/orchestrate.yml`
- Airflow stub: `airflow/README.md`
- CI (PR gate): `.github/workflows/ci.yml`, `pre-commit.yml`
- Demo Part F: `docs/demo-agenda.md`
