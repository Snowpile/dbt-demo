"""Install dependencies from requirements.json. Prefer: ./setup.sh"""

import json
from pathlib import Path

from setuptools import setup


def _load_requirements() -> dict:
    data = json.loads(Path("requirements.json").read_text(encoding="utf-8"))
    return {
        "name": "benderik",
        "version": "0.1.0",
        "description": "Data engineering — dbt (DuckDB) multi-domain",
        "python_requires": ">=3.10",
        "install_requires": data.get("install_requires", []),
        "extras_require": data.get("extras_require", {}),
        "packages": [],
    }


if __name__ == "__main__":
    setup(**_load_requirements())
