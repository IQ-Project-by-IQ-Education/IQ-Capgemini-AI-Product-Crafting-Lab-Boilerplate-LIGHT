---
name: force-serverbased
description: >
  TRAINER ONLY. Use when a trainer types "/force-serverbased", "$force-serverbased",
  or asks to force the app to run on localhost instead of from the file,
  optionally with a specific server (powershell, perl, node, python). Overrides
  the mode /kickoff chose: starts a server, switches lab-mode.txt to localhost
  mode and opens the app. Works on Mac and Windows.
disable-model-invocation: true
---

<!-- Claude Code entry point. The real instructions are shared with Codex and live in
     .agents/skills/force-serverbased/ — edit them there, not here. If you change the skill's name
     or description there, copy it into this file's header too. -->

Read `.agents/skills/force-serverbased/SKILL.md` (from the project root) and follow it exactly, as if its content were written here. Any scripts or files it mentions are in `.agents/skills/force-serverbased/`. Also follow `GUARDRAILS.md` at the project root at all times.

These instructions are shared with Codex. When they say "Codex", read it as you (Claude Code):
- Codex file tools → your Read / Edit / Write tools.
- Codex terminal tool → your Bash tool (on Windows, call `powershell.exe -NoProfile -Command "..."` through it when PowerShell is required).
- "Approve for me" / default shell access on Codex → Claude Code's permission mode. Report whether commands ran without a permission prompt or whether each one needed approval.
- Codex in-app browser → any browser tool you have (for example Claude in Chrome or Playwright) opened on the app's link from `lab-mode.txt` (or `file:///.../index.html` before `/kickoff`); if none is available, open the page with `Start-Process` / `open` and ask the user what they see.
- Never install anything or start a server yourself to run or check the app. Servers are started only through the launcher in `tools/` (`launch.ps1` / `launch.sh`).
