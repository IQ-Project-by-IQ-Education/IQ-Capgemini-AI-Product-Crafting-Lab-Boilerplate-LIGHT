---
name: launch-serverbased
description: >
  TRAINER ONLY. Use when a trainer types "/launch-serverbased", "$launch-serverbased",
  or asks to force the app to run on localhost with the built-in Windows server
  (tools/serve.ps1) instead of from the file. Overrides the mode /kickoff chose:
  starts the server, switches lab-mode.txt to localhost mode and opens the app.
disable-model-invocation: true
---

<!-- Claude Code entry point. The real instructions are shared with Codex and live in
     .agents/skills/launch-serverbased/ — edit them there, not here. If you change the skill's name
     or description there, copy it into this file's header too. -->

Read `.agents/skills/launch-serverbased/SKILL.md` (from the project root) and follow it exactly, as if its content were written here. Any scripts or files it mentions are in `.agents/skills/launch-serverbased/`. Also follow `GUARDRAILS.md` at the project root at all times.

These instructions are shared with Codex. When they say "Codex", read it as you (Claude Code):
- Codex file tools → your Read / Edit / Write tools.
- Codex terminal tool → your Bash tool (on Windows, call `powershell.exe -NoProfile -Command "..."` through it when PowerShell is required).
- "Approve for me" / default shell access on Codex → Claude Code's permission mode. Report whether commands ran without a permission prompt or whether each one needed approval.
- Codex in-app browser → any browser tool you have (for example Claude in Chrome or Playwright) opened on the app's link from `lab-mode.txt` (or `file:///.../index.html` before `/kickoff`); if none is available, open the page with `Start-Process` / `open` and ask the user what they see.
- Never use npm, node, python or any other local server to run or check the app. The only server allowed is the built-in `tools/serve.ps1`.
