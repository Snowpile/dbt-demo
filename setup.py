import json

from setuptools import find_packages, setup

with open("requirements.json") as fp:
    requirements = json.load(fp)

setup(
    name="benderik",
    description="Data engineering — dbt (DuckDB) multi-domain",
    version="0.1.0",
    packages=find_packages(exclude=["tests"]),
    python_requires=">=3.11",
    install_requires=requirements["install_requires"],
    extras_require=requirements["extras_require"],
)
