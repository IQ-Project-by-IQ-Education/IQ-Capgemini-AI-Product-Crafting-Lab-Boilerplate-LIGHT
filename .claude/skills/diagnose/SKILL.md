---
name: diagnose
description: >
  Use this skill when the user types "/diagnose", "$diagnose", "/diagnostic",
  "run diagnostic", "readiness check", or asks whether a Capgemini laptop
  (Windows or Mac) is ready for the AI Product Crafting Lab LIGHT starter:
  browser present, project unzipped locally, files intact, and the app page
  opening and saving data in the browser. Needs nothing installed.
---

<!-- Claude Code entry point. The real instructions are shared with Codex and live in
     .agents/skills/diagnose/ — edit them there, not here. If you change the skill's name
     or description there, copy it into this file's header too. -->

Read `.agents/skills/diagnose/SKILL.md` (from the project root) and follow it exactly, as if its content were written here. Any scripts or files it mentions are in `.agents/skills/diagnose/`. Also follow `GUARDRAILS.md` at the project root at all times.

These instructions are shared with Codex. When they say "Codex", read it as you (Claude Code):
- Codex file tools → your Read / Edit / Write tools.
- Codex terminal tool → your Bash tool (on Windows, call `powershell.exe -NoProfile -Command "..."` through it when PowerShell is required).
- "Approve for me" / default shell access on Codex → Claude Code's permission mode. Report whether commands ran without a permission prompt or whether each one needed approval.
- Codex in-app browser → any browser tool you have (for example Claude in Chrome or Playwright) opened on the app's link from `lab-mode.txt` (or `file:///.../index.html` before `/kickoff`); if none is available, open the page with `Start-Process` / `open` and ask the user what they see.
- Never use npm, node, python or any other local server to run or check the app. The only server allowed is the built-in `tools/serve.ps1`.
