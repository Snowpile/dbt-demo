---
name: token-lean
description: >-
  Token-lean workflows for this dbt repo in Cursor, Claude Code, or similar.
  Use when starting a session, drafting prompts, choosing what to @-reference,
  deciding whether to spawn subagents, or when the user asks how to keep
  context small.
---

# Token-lean practices

How to work on this repo with the fewest tokens.
**Meeting walkthrough:** Part E of `docs/demo-agenda.md`.

## Shared (all tools)

- **`AGENTS.md` is auto-loaded / primary** — stack, commands, autonomy matrix. Don't restate it in prompts.
- **`docs/STATUS.md`** — read first on a new chat; **update at end of every session** per `.agents/skills/session-handoff/SKILL.md`.
- **`@`-reference or name paths** — don't paste whole files, logs, or specs into chat.
- **Scoped asks** — "fix RF02 in `finance_fct_order_revenue`" beats "review everything".
- **Let the agent search** rather than dumping content into chat.
- **Subagents for broad exploration** — parent synthesizes a short answer; main thread stays small.
- **Targeted diffs**, not full-file rewrites. Short replies, no drive-by refactors.
- **Load `docs/` only when the task needs depth.**
- **Multi-project dbt:** always `cd mart_<domain>` before dbt commands.
- **Only the human commits/pushes** — AI may stage + propose a message; never `git commit`/`push`
  (see `AGENTS.md`).

## Cursor

- Use **`@docs/STATUS.md`**, **`@AGENTS.md`**, etc. so the agent reads only what it needs.
- **Fresh chat when context gets long or stale** — resume via `docs/STATUS.md`.
- Project skills live under `.agents/skills/` (AI-agnostic); Cursor also has user-level built-ins.

## Claude Code

- **`CLAUDE.md`** imports `AGENTS.md` — same durable context, no duplication needed.
- **No MCP in this repo** — terminal + repo files only.
- **Batch independent tool calls in parallel** instead of one-at-a-time.

## Don't

- Paste long logs, whole files, or specs — point to the path.
- Keep one mega-chat for days — context bloat wastes tokens and hurts answers.
- Re-explain conventions already in `AGENTS.md` or skills.
- Echo back large file contents you just read.
- Run a command twice just to show output — capture once.

## Resume a session (new chat)

> Read `docs/STATUS.md` and continue.

The agent should read **Resume here** in `STATUS.md` and pick up without re-litigating prior decisions.
