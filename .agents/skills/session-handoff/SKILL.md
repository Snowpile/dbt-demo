---
name: session-handoff
description: >-
  End-of-session and new-chat handoff for this repo. Use when ending a working
  session, opening a fresh chat, updating docs/STATUS.md, or when the user says
  they are switching chats.
---

# Session handoff

**Before ending a working session** (or when the user says they're opening a new chat), update handoff files so the next agent needs no conversation history.

## Required: `docs/STATUS.md`

Update **every** session. Set `Last updated` to today. Keep these sections current:

| Section | What to write |
|---------|----------------|
| **Snapshot** | Repo facts that changed (paths, scripts, build status, CI) |
| **Last session** | What we did this chat (bullets); decisions made |
| **Resume here** | Single explicit next action (file + section) |
| **Next session** | Ordered steps if more than one thing remains |
| **Open items** | Blockers, unanswered questions, uncommitted work worth noting |
| **Resume quickly** | Commands to run first in a fresh terminal |

Do not rely on chat memory — if it is not in `STATUS.md`, the next chat does not know it.

## Also update when relevant

| File | When |
|------|------|
| `DEMO_CHECKLIST.md` | While it exists — demo prep progress / Phase 2+ backlog *(planned removal after prep)* |
| `docs/demo-agenda.md` | Runbook commands or flow changed |

## New chat startup (agent)

1. Read `docs/STATUS.md` first — especially **Resume here** and **Last session**.
2. Read other trackers only if the task needs them.
3. Continue from **Resume here** without re-asking what was already decided.

## User prompt for a fresh chat

> Read `docs/STATUS.md` and continue.
