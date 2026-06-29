# AI practices — Cursor (token-lean)

*How to work in Cursor on this repo with the fewest tokens. Read once; apply always.*

## Do

- **`@`-reference files/folders** instead of pasting their contents (e.g. `@docs/STATUS.md`). The agent reads only what it needs.
- **Start a fresh chat when context gets long or stale.** Resume via `docs/STATUS.md` — don't re-explain history.
- **Lean on the rules.** `AGENTS.md` + `.cursor/rules/*.mdc` are auto-loaded every chat; don't repeat that context in prompts.
- **Ask scoped questions** ("fix RF02 in `finance_fct_order_revenue`") over broad ones ("review everything").
- **Let the agent search** (Grep/semantic) rather than pasting large files or logs.
- **Use subagents for broad exploration**; the parent synthesizes a short answer. Keeps the main thread small.
- **Request targeted diffs**, not full-file rewrites.

## Don't

- Paste long logs, whole files, or specs into chat — point to the path instead.
- Keep one mega-chat running for days; context bloat = wasted tokens + worse answers.
- Re-describe the stack/conventions — they live in `AGENTS.md`.
- Ask for "explain everything"; ask for the specific thing you need.

## Resume a session (new chat)

> Read `docs/STATUS.md` and continue. (The rules force this automatically.)
