---
name: iq-project-slides
description: >
  Use this skill when the user types "/iq-project-slides", "$iq-project-slides",
  "slides", "open the slides", "show the slides", or asks to open the Capgemini
  AI Product Crafting Lab presentation/deck.
---

<!-- Claude Code entry point. The real instructions are shared with Codex and live in
     .agents/skills/iq-project-slides/ — edit them there, not here. If you change the skill's name
     or description there, copy it into this file's header too. -->

Read `.agents/skills/iq-project-slides/SKILL.md` (from the project root) and follow it exactly, as if its content were written here. Any scripts or files it mentions are in `.agents/skills/iq-project-slides/`. Also follow `GUARDRAILS.md` at the project root at all times.

These instructions are shared with Codex. When they say "Codex", read it as you (Claude Code):
- Codex file tools → your Read / Edit / Write tools.
- Codex terminal tool → your Bash tool (on Windows, call `powershell.exe -NoProfile -Command "..."` through it when PowerShell is required).
- "Approve for me" / default shell access on Codex → Claude Code's permission mode. Report whether commands ran without a permission prompt or whether each one needed approval.
- Codex in-app browser → any browser tool you have (for example Claude in Chrome or Playwright) opened on the app's link from `lab-mode.txt` (or `file:///.../index.html` before `/kickoff`); if none is available, open the page with `Start-Process` / `open` and ask the user what they see.
- Never install anything or start a server yourself to run or check the app. Servers are started only through the launcher in `tools/` (`launch.ps1` / `launch.sh`).
