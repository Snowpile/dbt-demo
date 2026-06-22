# GitHub — push branches & open PRs

Repo: **`benderik`** on your personal GitHub account.

## One-time setup

```bash
# 1. Create empty repo on GitHub (no README if you already have local files)
#    https://github.com/new → name: benderik

# 2. Link remote (replace YOUR_USER)
git remote add origin git@github.com:YOUR_USER/benderik.git
# or HTTPS: git remote add origin https://github.com/YOUR_USER/benderik.git

# 3. Auth — pick one:
#    SSH: ssh-keygen -t ed25519 && add ~/.ssh/id_ed25519.pub to GitHub → Settings → SSH keys
#    HTTPS + gh: gh auth login

# 4. First push
git push -u origin main
```

## AI / you — branch + PR workflow

```bash
git checkout -b feat/my-change
# ... work, commit when ready ...
git push -u origin feat/my-change
gh pr create --title "..." --body "..."
```

**`gh` CLI** (recommended for AI opening PRs): `sudo apt install gh` or see https://cli.github.com — then `gh auth login`.

## What AI may do (see `AGENTS.md`)

- Create branches, push, open PRs via `gh pr create`
- Never commit unless you explicitly ask
- CI runs on every PR: seed scan → load raw → `dbt build` all projects
