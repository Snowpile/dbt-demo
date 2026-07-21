---
name: make-pr
description: >-
  Open or refresh a GitHub PR with a filled description from
  .github/pull_request_template.md and branch diff vs main. Use after the human
  pushes a branch, when the user says make/open/update a PR, or at end of work
  before merge.
---

# Make PR

Open (or refresh) a PR whose body matches `.github/pull_request_template.md`, filled from the branch diff.

**Guardrails (repo):**
- **Human commits and pushes** — never `git commit` / `git push` (see `AGENTS.md`).
- **Agent may** run read-only git, render the body, and `gh pr create` / `gh pr edit` after push.
- Template source of truth: `.github/pull_request_template.md` — keep renderer aligned when the template changes.

## When to run

- User pushed a feature branch and wants a PR.
- User says “open PR”, “make PR”, “update PR description”.
- After scoped work is done and commits exist on the remote branch.

Do **not** open empty or placeholder-only PRs — ensure `origin/<branch>` is ahead of `main`.

## Workflow

### 1. Preconditions

```bash
git fetch origin main
git status -sb
git log origin/main..HEAD --oneline
```

Stop if: on `main`, no commits ahead of `main`, or branch not pushed (`git status` shows ahead without upstream).

### 2. Render body (parallel with step 1)

```bash
python3 .agents/skills/make-pr/render_body.py origin/main > /tmp/pr_render.txt
```

Parse output:
- Line `TITLE:...` → proposed PR title (prefix with `Feature:` / `Fix:` / `Docs:` / `Chore:` if missing).
- After `---BODY---` → PR body markdown.

### 3. Enrich (agent, required)

Read the diff (`git diff origin/main...HEAD`) and **edit the rendered body** before `gh`:

| Section | Agent fills |
|---------|-------------|
| **Motivation** | Replace placeholder — why this change, demo/CI context |
| **Summary** | Tighten bullets; not raw commit dump if messy |
| **Scope** | Fix notes; confirm checkboxes |
| **Validation** | Paste local results if you ran builds/tests; else “CI pending” |
| **Changes to existing models** | Mark breaking / full-refresh if applicable |
| **Checklist** | Check `[x]` only for items you verified |

Drop **DAG / lineage** or **To-do before merge** if N/A. Delete HTML comments before submitting.

### 4. Create or update PR

**Check for existing PR:**

```bash
gh pr view --json number,url 2>/dev/null
```

**Create** (no open PR; branch already on `origin`):

```bash
gh pr create --base main --title "Feature: …" --body "$(cat <<'EOF'
…filled body…
EOF
)"
```

**Update** (PR exists — e.g. after a new push):

```bash
gh pr edit --title "…" --body "$(cat <<'EOF'
…filled body…
EOF
)"
```

Return the PR URL to the user.

### 5. Post-open

- Note expected CI: `pre-commit` + `ci` (`slim-pr`).
- If model changes: remind to watch Slim CI / dbt-checkpoint on the PR.

## Title conventions

Match template header examples:

| Change type | Title prefix |
|-------------|--------------|
| New model / feature | `Feature:` |
| Bug / CI fix | `Fix:` |
| Docs / agenda / STATUS | `Docs:` |
| Tooling / deps / chores | `Chore:` |

## Scope mapping (auto)

`render_body.py` maps paths → Scope table rows (finance/marketing/operations/combined, seeds, scripts, `.github/`, docs, orchestration). Models listed from `mart_*/models/**/*.sql` basenames.

## Troubleshooting

| Issue | Action |
|-------|--------|
| `no changes vs base` | Wrong base or branch not ahead of `main` |
| `gh: not found` | User installs/auths `gh` |
| No remote branch | Human must `git push -u origin HEAD` first |
| Template changed | Update `render_body.py` sections to match |

## Related

- PR template: `.github/pull_request_template.md`
- CI / Slim: `docs/defer.md`, `.github/workflows/ci.yml`
- Git policy: `AGENTS.md` (GitHub / PR workflow)
