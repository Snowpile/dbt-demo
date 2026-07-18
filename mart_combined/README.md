# mart_combined — all-domain Docs DAG

**Docs only.** Installs `mart_finance`, `mart_marketing`, and `mart_operations` as
local packages so `dbt docs` can show one lineage graph. Not part of CI,
`bootstrap.sh`, or slim builds.

```bash
# from repo root (after . ./setup.sh)
./dbt_docs.sh mart_combined    # → http://127.0.0.1:8010
```

Under the hood: `dbt deps` → vendor marketing/operations copies → strip duplicate
shared `{% docs %}` → `dbt docs generate --empty-catalog` → `docs serve`.
Does not change the three domain projects on disk (finance stays a symlink;
marketing/operations are temporary copies under `dbt_packages/`).
