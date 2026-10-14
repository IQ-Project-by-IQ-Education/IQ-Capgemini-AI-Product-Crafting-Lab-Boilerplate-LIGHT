# Skills — LIGHT starter

Skills work in **Codex** and **Claude Code**.

- **Codex** reads them from `.agents/skills/<name>/SKILL.md` (card shown in the app: `agents/openai.yaml`). Call with `$name` or `/name`.
- **Claude Code** reads the pointer files in `.claude/skills/<name>/SKILL.md`, which send it to the same `.agents/skills/` instructions. Call with `/name`.
- Any other agent: `AGENTS.md` lists the trigger phrases and the file to follow.

Edit a skill only in `.agents/skills/`. If you change its name or description, copy the new header into its `.claude/skills/` pointer. Do not add a `.codex/skills/` folder (Codex would list every skill twice).

Every skill ends with the same **Lab guardrails** block (no npm/node/python, no server, no framework, no modules or local `fetch()`, no second HTML page; outside services only if they work, hard rule: after 5 minutes without success, back to the base boilerplate). The full list is `GUARDRAILS.md`.

| Skill | For | What it does | Changed from the Next.js starter |
|---|---|---|---|
| `/diagnose` | IT / helpers, before the session | Runs `scripts/diagnose.ps1` (Windows PowerShell 5.1) or `scripts/diagnose.sh` (macOS): Edge/Chrome present, unzipped on a local disk (FAIL inside zip / network drive, WARN under OneDrive), all files present, `vendor/sql-asm.js` intact (1,355,169 bytes + checksum), browser policies blocking storage / JavaScript / `file://` / downloads / file picker. Then opens `index.html` and confirms the **Items** screen (browser tool, or one question to the helper). Prints a PASS / FAIL report. | Replaces `/diagnostic-mac` and `/diagnostic-windows`. All Node / npm / Git / Python / npm-install stress tests removed. |
| `/kickoff` | Participant | Sets `APP_NAME` in `js/config.js` from the spec, leaves the items example, opens `index.html` (`Start-Process` / `start` on Windows, `open` on macOS), confirms **Items**, gives the `file://` link to bookmark. | No `npm install`, no `npm run dev`, no localhost. Nothing is installed or started. |
| `/givemeideas` | Participant | Four executive-friendly app ideas. | Unchanged (guardrail added). |
| `/masterprompt` | Participant | Opens the master prompt maker, then points to `/kickoff`. | Kickoff wording ("open", not "install and run"). |
| `/capgemini-ui-design` | Agent | Capgemini colors, type, components, logo. Output goes to `styles.css` and the `render()` templates in `js/app.js`. | Google Fonts optional with system-font fallback, no `next/image`, logo at `assets/capgemini-logo.png` (relative path). |
| `/capture-bug` | Participant | Collects the bug context step by step (in French), then fixes it. | Browser console only (no terminal), "Loading…" / "site storage is disabled" cases, F5 to see changes, fixes only in `js/app.js` / `js/schema.js` / `styles.css`. |
| `/iq-project-slides` | Participant | Opens the lab slides. | Unchanged (guardrail added). |

Removed: `scripts/npm-install-test.sh` and `scripts/npm-install-test.ps1` (their only purpose was testing npm installs).
