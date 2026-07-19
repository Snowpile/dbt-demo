# Airflow orchestration stub

**Status:** documentation-only stub. No runnable DAGs are checked in. Airflow is included
because it is a widely used industry standard — alongside GitHub Actions and Prefect.

## Docs

- [Apache Airflow documentation](https://airflow.apache.org/docs/)
- [Airflow quick start](https://airflow.apache.org/docs/apache-airflow/stable/start.html)
- [Authoring DAGs](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html)
- [Providers index](https://airflow.apache.org/docs/apache-airflow-providers/index.html) (Docker, K8s, cloud, …)

## Why it is here

Teams often standardize on Airflow for schedules, retries, and multi-system DAGs. This stub
shows where a `dbt_demo` DAG would live; the demo itself still runs via scripts / CI.

## Dependencies (not installed by default)

`./setup.sh` only installs `.[dev]`. Airflow packages live under the `airflow` extra in
`requirements.json` (treated as commented-out until you opt in):

```bash
# uv pip install -e '.[airflow]'
# # which pulls: apache-airflow>=2.9.0,<3
# # optional later:
# # apache-airflow-providers-docker
# # apache-airflow-providers-cncf-kubernetes
```

Airflow installs are heavy; use a dedicated venv or containers in real deployments.

## Intended shape (when implemented)

```text
orchestration/airflow/
  README.md           ← you are here
  dags/
    dbt_demo_daily.py ← DAG: scan → load_raw → dbt_build_all (not committed yet)
  plugins/            ← optional custom operators
```

Pseudo-DAG:

```python
# NOT wired — illustrative only
from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id="dbt_demo_daily",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
) as dag:
    bootstrap = BashOperator(
        task_id="bootstrap",
        bash_command="cd /opt/dbt-demo && ./scripts/bootstrap.sh",
    )
```

## Local alternative today

```bash
. ./setup.sh
./scripts/bootstrap.sh
```

## Related

- GitHub Actions: `.github/workflows/orchestrate.yml`
- Prefect stub: `orchestration/prefect/README.md`
- CI (PR gate): `.github/workflows/ci.yml`, `pre-commit.yml`
- Demo Part D (production path): `docs/demo-agenda.md`
