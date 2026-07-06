# GitHub — remote setup & PR workflow

Repo: **`dbt-demo`** on GitHub ([`Snowpile/dbt-demo`](https://github.com/Snowpile/dbt-demo)). Local folder and dbt profile use `dbt_demo` (underscore). **CI pipeline walkthrough:** Part B of `docs/demo-agenda.md`.

## Remote URL

```bash
git remote set-url origin git@github-snowpile:Snowpile/dbt-demo.git
```

## One-time setup

```bash
# 1. Create empty repo on GitHub (no README if you already have local files)
#    https://github.com/new → name: dbt-demo

# 2. Link remote (replace YOUR_USER)
git remote add origin git@github.com:YOUR_USER/dbt-demo.git

# 3. Auth — SSH key or: gh auth login

# 4. First push
git push -u origin main
```

## Branch + PR workflow

```bash
git checkout -b feat/my-change
# ... work; human commits when ready ...
git push -u origin feat/my-change
gh pr create --title "..." --body "..."
```

**`gh` CLI:** https://cli.github.com — then `gh auth login`.

## What AI may do

See autonomy matrix in `AGENTS.md`. Summary: create branches, read-only git, stage files,
open PRs via `gh` — **never commit/push unless you explicitly ask**.
