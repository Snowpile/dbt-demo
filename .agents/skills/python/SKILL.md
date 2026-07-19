---
name: python
description: >-
  Python conventions for this repo (uv, Ruff, scripts). Use when editing
  *.py under scripts/, setup.py, or Python tooling/config.
---

# Python

- Deps: **uv** — `./setup.sh` (`uv venv` + `uv pip install -e ".[dev]"`); add packages in `requirements.json`.
- **Lint + format: Ruff only** — config in `ruff.toml`. Do not add Black, Flake8, isort, pylint, or mypy unless explicitly requested.
  - Local: `ruff check .` / `ruff format .` (or `pre-commit run ruff-check ruff-format --all-files`)
  - CI: `pre-commit.yml` runs the same Ruff hooks on changed files.
- Config via env vars; never hardcode secrets.
- Type hints on public functions; no bare `except`.
