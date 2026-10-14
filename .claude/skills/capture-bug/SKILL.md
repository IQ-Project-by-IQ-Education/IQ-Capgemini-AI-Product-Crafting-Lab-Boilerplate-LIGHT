---
name: capture-bug
description: Guide une personne non technique à décrire un bug et à récupérer le contexte utile (message d'erreur, étapes, console, capture) pour qu'une IA puisse ensuite le résoudre. À déclencher quand l'utilisateur dit "ça marche pas", "j'ai une erreur", "mon site bug", "ça plante", "page blanche", ou montre un problème sans savoir l'expliquer techniquement.
argument-hint: "<décris ce qui ne marche pas, même approximativement>"
---

<!-- Claude Code entry point. The real instructions are shared with Codex and live in
     .agents/skills/capture-bug/ — edit them there, not here. If you change the skill's name
     or description there, copy it into this file's header too. -->

Read `.agents/skills/capture-bug/SKILL.md` (from the project root) and follow it exactly, as if its content were written here. Any scripts or files it mentions are in `.agents/skills/capture-bug/`. Also follow `GUARDRAILS.md` at the project root at all times.

These instructions are shared with Codex. When they say "Codex", read it as you (Claude Code):
- Codex file tools → your Read / Edit / Write tools.
- Codex terminal tool → your Bash tool (on Windows, call `powershell.exe -NoProfile -Command "..."` through it when PowerShell is required).
- "Approve for me" / default shell access on Codex → Claude Code's permission mode. Report whether commands ran without a permission prompt or whether each one needed approval.
- Codex in-app browser → any browser tool you have (for example Claude in Chrome or Playwright) opened on the `file:///.../index.html` link; if none is available, open the page with `Start-Process` / `open` and ask the user what they see.
- Never fall back to npm, node, python, a local server or `curl http://localhost` to check the app — there is no server in this lab.
