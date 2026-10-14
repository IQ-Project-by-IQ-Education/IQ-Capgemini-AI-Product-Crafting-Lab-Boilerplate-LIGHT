---
name: kickoff
description: >
  Use this skill when the user types "/kickoff", "$kickoff", "kick off",
  "start the challenge", "start the app", or asks to launch the Capgemini AI
  Product Crafting Lab LIGHT starter. Names the app, opens index.html in the
  browser and confirms it shows "Items". Nothing is installed or started.
---

<!-- Claude Code entry point. The real instructions are shared with Codex and live in
     .agents/skills/kickoff/ — edit them there, not here. If you change the skill's name
     or description there, copy it into this file's header too. -->

Read `.agents/skills/kickoff/SKILL.md` (from the project root) and follow it exactly, as if its content were written here. Any scripts or files it mentions are in `.agents/skills/kickoff/`. Also follow `GUARDRAILS.md` at the project root at all times.

These instructions are shared with Codex. When they say "Codex", read it as you (Claude Code):
- Codex file tools → your Read / Edit / Write tools.
- Codex terminal tool → your Bash tool (on Windows, call `powershell.exe -NoProfile -Command "..."` through it when PowerShell is required).
- "Approve for me" / default shell access on Codex → Claude Code's permission mode. Report whether commands ran without a permission prompt or whether each one needed approval.
- Codex in-app browser → any browser tool you have (for example Claude in Chrome or Playwright) opened on the `file:///.../index.html` link; if none is available, open the page with `Start-Process` / `open` and ask the user what they see.
- Never fall back to npm, node, python, a local server or `curl http://localhost` to check the app — there is no server in this lab.
