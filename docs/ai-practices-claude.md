# AI practices — Claude (token-lean)

*How Claude should work on this repo with the fewest tokens. Read once; apply always.*

## Context & memory

- `AGENTS.md` (and `CLAUDE.md`, which just imports it) is **auto-loaded** — durable context lives there. Don't restate it.
- Read `docs/STATUS.md` first on a new chat; update it at the end so the next chat resumes fast.
- **No MCP in this repo** — use terminal + repo files only.

## Working style

- **Short replies, small diffs.** No preamble, no drive-by refactors, no unsolicited docs.
- **Batch independent tool calls in parallel** (e.g. several reads at once) instead of one-at-a-time.
- **Don't read huge files end-to-end** — target with Grep/semantic search, then read the relevant range.
- **Subagents for broad exploration**; the parent synthesizes a short result. Keeps the main context small.
- Load `docs/` only when the task needs depth; don't paste long specs into chat.

## Repo specifics

- Multi-project dbt: **`cd projects/<domain>` before any dbt command**.
- Prefer repo files over pretraining for stack/business rules.
- **Only the human commits/pushes** — never run `git commit`/`push`/`merge`/`rebase`/`reset` (see `.cursor/rules/core.mdc`).

## Don't

- Echo back large file contents you just read.
- Re-explain conventions already in `AGENTS.md`.
- Run a command, then re-run it just to show output — capture once.
