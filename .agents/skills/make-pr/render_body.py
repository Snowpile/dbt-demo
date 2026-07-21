#!/usr/bin/env python3
"""Render a PR body from .github/pull_request_template.md + git diff vs base."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
TEMPLATE = REPO_ROOT / ".github" / "pull_request_template.md"

SCOPE_RULES: list[tuple[str, str]] = [
    (r"^mart_finance/", "`mart_finance`"),
    (r"^mart_marketing/", "`mart_marketing`"),
    (r"^mart_operations/", "`mart_operations`"),
    (r"^mart_combined/", "`mart_combined` (docs-only)"),
    (r"^data/seeds/", "Seeds / `load_raw`"),
    (r"^(scripts/|setup\.sh|dbt_docs\.sh)", "Scripts / `setup.sh`"),
    (r"^\.github/", "CI / workflows (`.github/`)"),
    (r"^(docs/|AGENTS\.md|CLAUDE\.md|README\.md)", "Docs (`docs/`, `AGENTS.md`, README)"),
    (r"^orchestration/", "Orchestration stubs"),
]


def run(*args: str) -> str:
    return subprocess.check_output(args, cwd=REPO_ROOT, text=True).strip()


def changed_files(base: str) -> list[str]:
    out = run("git", "diff", "--name-only", f"{base}...HEAD")
    return [line for line in out.splitlines() if line]


def commit_subjects(base: str) -> list[str]:
    out = run("git", "log", f"{base}..HEAD", "--format=%s")
    return [line for line in out.splitlines() if line]


def model_names(files: list[str]) -> list[str]:
    names: list[str] = []
    for path in files:
        m = re.match(r"mart_(?:finance|marketing|operations)/models/(?:.*/)?([^/]+)\.sql$", path)
        if m and not m.group(1).startswith("_"):
            names.append(m.group(1))
    return sorted(set(names))


def scope_hits(files: list[str]) -> dict[str, list[str]]:
    hits: dict[str, list[str]] = {label: [] for _, label in SCOPE_RULES}
    for path in files:
        for pattern, label in SCOPE_RULES:
            if re.search(pattern, path):
                hits[label].append(path)
    return hits


def primary_domain(files: list[str]) -> str | None:
    for prefix in ("mart_finance", "mart_marketing", "mart_operations"):
        if any(f.startswith(f"{prefix}/") for f in files):
            return prefix
    return None


def suggest_title(commits: list[str], branch: str) -> str:
    if commits:
        subj = commits[0]
        if re.match(r"^(feat|fix|docs|chore|ci)(\(.+\))?:", subj, re.I):
            return subj.split(":", 1)[-1].strip().title() if ":" in subj else subj
        return subj[:72]
    slug = branch.replace("/", " ").replace("-", " ").replace("_", " ").strip()
    return slug.title()[:72] if slug else "Update"


def render_scope_table(hits: dict[str, list[str]]) -> str:
    lines = [
        "| Area | Touched? | Notes |",
        "|------|----------|-------|",
    ]
    for _, label in SCOPE_RULES:
        touched = hits[label]
        mark = "☑" if touched else "☐"
        note = ", ".join(Path(p).name for p in touched[:4])
        if len(touched) > 4:
            note += f" (+{len(touched) - 4} more)"
        lines.append(f"| {label} | {mark} | {note or ''} |")
    return "\n".join(lines)


def render_validation(files: list[str], models: list[str], domain: str | None) -> str:
    has_models = bool(models)
    has_ci = any(f.startswith(".github/") for f in files)
    has_seeds = any(f.startswith("data/seeds/") for f in files)

    if domain and models:
        select = " ".join(models[:3])
        if len(models) > 3:
            select += " ..."
        build_block = f"""```bash
. ./setup.sh
./scripts/load_raw.sh
cd {domain}
dbt build --select {select}+
# Slim vs main (optional):
# ../scripts/slim_build.sh {domain}
```"""
    elif has_ci or any(f.startswith("scripts/") for f in files):
        build_block = """```bash
. ./setup.sh
# CI-only: push branch and confirm pre-commit + CI (slim-pr) on the PR
```"""
    else:
        build_block = """```bash
. ./setup.sh
# Docs/chore: no dbt build required unless you changed runnable commands
```"""

    ci_note = (
        "PR should show **pre-commit** (changed files) + **CI slim-pr** (`state:modified+ --defer`)."
        if has_models or has_ci or has_seeds
        else "PR should show **pre-commit** on changed files."
    )

    return f"""**Local (as applicable):**

{build_block}

| Check | Result |
|-------|--------|
| `dbt build` / tests on selected nodes | {"☐ pass" if has_models else "☐ n/a"} |
| Ad-hoc SQL / row counts (`./scripts/sql.sh`) | ☐ n/a · ☐ done |
| Incremental: second run + optional `--full-refresh` | ☐ n/a · ☐ done |
| Defer / Slim locally if refs left unbuilt | {"☐ n/a · ☐ done" if has_models else "☐ n/a"} |

**CI:** {ci_note}

- _(Agent: fill after local runs or once CI finishes.)_
"""


def is_docs_only(hits: dict[str, list[str]], files: list[str]) -> bool:
    doc_only = hits.get("Docs (`docs/`, `AGENTS.md`, README)", [])
    ci_only = hits.get("CI / workflows (`.github/`)", [])
    model_paths = [f for f in files if re.search(r"^mart_.*/models/.*\.sql$", f)]
    return not model_paths and (
        doc_only or ci_only or all(f.endswith(".md") or f.startswith(".agents/") for f in files)
    )


def main() -> int:
    base = sys.argv[1] if len(sys.argv) > 1 else "origin/main"
    try:
        branch = run("git", "branch", "--show-current")
        files = changed_files(base)
        commits = commit_subjects(base)
        models = model_names(files)
        hits = scope_hits(files)
        domain = primary_domain(files)
        docs_only = is_docs_only(hits, files)
    except subprocess.CalledProcessError as exc:
        print(f"error: git failed ({exc})", file=sys.stderr)
        return 1

    if not files:
        print("error: no changes vs base — nothing to PR", file=sys.stderr)
        return 1

    title = suggest_title(commits, branch)
    summary_bullets = "\n".join(f"- {s}" for s in commits[:5])
    if len(commits) > 5:
        summary_bullets += f"\n- _(+{len(commits) - 5} more commits)_"

    models_line = ", ".join(f"`{m}`" for m in models) if models else "_none_"

    body_parts = [
        f"<!-- render_body.py vs {base} · branch {branch} -->",
        "",
        "## Summary",
        "",
        summary_bullets,
        "",
        "## Motivation",
        "",
        "<!-- Why now? One short paragraph — edit before opening PR. -->",
        "",
        "## Scope",
        "",
        render_scope_table(hits),
        "",
        f"**Models / macros of note:** {models_line}",
        "",
    ]

    if any(f.startswith("mart_") and "/models/" in f for f in files):
        body_parts.extend(
            [
                "## DAG / lineage",
                "",
                "```bash",
                f"./dbt_docs.sh {domain or 'mart_finance'}          # domain",
                "# or: ./dbt_docs.sh mart_combined   # all-domain DAG :8010",
                "```",
                "",
                "<!-- Paste screenshot or describe nodes added/changed -->",
                "",
            ]
        )

    body_parts.extend(
        [
            "## Validation",
            "",
            render_validation(files, models, domain),
            "",
            "## Changes to existing models",
            "",
            "- Breaking / contract change? ☐ no · ☐ yes — detail:",
            "- Full refresh required after merge? ☐ no · ☐ yes — model(s):",
            "- Downstream / exposure impact? ☐ no · ☐ yes —",
            "",
            "## Checklist",
            "",
            "### Shape of the PR",
            "",
            "- [ ] One logical piece of work; commits are related and readable",
        ]
    )

    if not docs_only:
        body_parts.extend(
            [
                "- [ ] Naming follows `{domain}_{layer}_{entity}` (`docs/conventions.md`)",
                "- [ ] New/changed mart PKs have `unique` + `not_null`",
                "- [ ] New/changed models have a description (dbt-checkpoint)",
                "- [ ] No raw table names in model SQL (`source()` / `ref()` only)",
                "- [ ] SQLFluff / Ruff clean on touched files (or CI lint green)",
            ]
        )

    body_parts.extend(
        [
            "- [ ] Docs updated when behavior or demo path changes",
            "",
            "### Skip / N/A",
            "",
        ]
    )

    if docs_only:
        body_parts.append("- [x] Docs-only / CI-only / chore — model checklist above mostly N/A")

    print(f"TITLE:{title}")
    print("---BODY---")
    print("\n".join(body_parts))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
