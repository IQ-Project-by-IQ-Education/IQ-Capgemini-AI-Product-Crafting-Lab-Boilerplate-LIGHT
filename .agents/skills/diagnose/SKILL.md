---
name: diagnose
description: >
  Use this skill when the user types "/diagnose", "$diagnose", "/diagnostic",
  "run diagnostic", "readiness check", or asks whether a Capgemini laptop
  (Windows or Mac) is ready for the AI Product Crafting Lab LIGHT starter:
  browser present, project unzipped locally, files intact, and the app page
  opening and saving data in the browser. Needs nothing installed.
---

# Diagnose

Laptop readiness check that Capgemini IT or a lab helper runs **before** the session. It must succeed with nothing installed: no Node, no npm, no Python, no Git. It only uses what ships with the computer (Windows PowerShell 5.1, or bash on macOS) and the browser.

The output is technical and meant for helpers / IQ Project, not for the COMEX builder. The final answer is a copy-paste PASS / FAIL report.

Rules:
- Run the checks yourself and record real evidence.
- Check and report only. Do not install anything, change settings, or "fix" the machine.
- Never check for Node, npm, npx, Python, pip, Git or any package manager — they are not needed and are expected to be blocked.
- Never start a server or use `localhost`.
- Do not create git commits.
- Do not claim more than you tested.

## Step 1 — Run the check script

From the project folder:

- **Windows:** `powershell -NoProfile -ExecutionPolicy Bypass -File .agents\skills\diagnose\scripts\diagnose.ps1 -Open edge`
  (use `-Open chrome` if Edge is missing).
- **macOS:** `bash .agents/skills/diagnose/scripts/diagnose.sh --open edge` (or `--open chrome`).

It checks, and prints one `PASS` / `WARN` / `FAIL` line each:
1. **Browser** — Microsoft Edge or Google Chrome present (path + version).
2. **Unzipped on a local disk** — FAIL if running from inside the zip or from a network drive; WARN if under OneDrive / iCloud.
3. **Boilerplate files** — `index.html`, `styles.css`, the five `js/` files, `vendor/sql-asm.js`, `AGENTS.md`, `GUARDRAILS.md`.
4. **`vendor/sql-asm.js` intact** — size ~1.35 MB (1,355,169 bytes) and checksum. A truncated or missing file usually means the zip was partly extracted or antivirus touched it.
5. **Browser policies** — looks for managed policies that would break the app: site storage blocked (`DefaultCookiesSetting=2`), JavaScript blocked, `file://` URLs blocked, downloads blocked (Export), file picker blocked (Import).
6. Opens `index.html` in the chosen browser and prints the app link.

**If the script is refused** (group policy, AppLocker, "running scripts is disabled"), report that exact message as a restriction, then do the same checks by hand with single commands:
- Windows: `Test-Path "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"`, `Get-Location`, `Test-Path .\index.html` (and each file above), `(Get-Item .\vendor\sql-asm.js).Length`, `Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Edge`, then `Start-Process .\index.html`.
- macOS: `ls /Applications | grep -i -E "edge|chrome"`, `pwd`, `ls index.html js vendor`, `wc -c vendor/sql-asm.js`, then `open index.html`.
- If even single commands are blocked, ask the helper to check by eye: the folder is unzipped (not opened inside the zip), and `vendor\sql-asm.js` is about 1.3 MB in File Explorer.

## Step 2 — Confirm the page reaches the start screen

This proves the browser runs the app **and** allows it to save data.

- If you have a browser tool (Codex in-app browser, Claude in Chrome, Playwright…), open the app link the script printed (`file:///.../index.html`), wait up to 10 seconds and read the page.
- Otherwise ask the helper one question: *"Look at the browser window that just opened. Does it show the Capgemini and IQ Project logos with **Build anything here**, or does it stay on **Loading…**?"*

Result:
- Shows **Build anything here** → `PASS`. If time allows, test saving: add `#/items` to the end of the address, click **New item**, save one, press F5, and confirm it is still there; then delete it.
- Shows the start screen with a red note **"This browser won't let the app keep your data"** → `WARN`: site storage (IndexedDB and localStorage) is disabled by policy for local files. The app works, but only in memory: data must be exported before closing. Try the other browser (Edge ↔ Chrome) and report both results.
- Stays on **Loading…** or shows **"The app could not start"** → `FAIL`: the app files are damaged or JavaScript is blocked. Check steps 3–4 and policies.
- Blank page / the file opens as text / download prompt → `FAIL`: `.html` files or `file://` pages are blocked.

Do not use headless browser tricks (`--headless --dump-dom`) for this step: the page saves data asynchronously and headless snapshots are taken too early.

## Output format (use exactly)

```text
CAPGEMINI AI PRODUCT CRAFTING LAB (LIGHT) - LAPTOP DIAGNOSTIC

Date/time:
Computer/user:
Operating system:
Project folder:
Agent used: Codex / Claude Code / other

PASS/WARN/FAIL  Browser (Edge or Chrome) ........ <name + version>
PASS/WARN/FAIL  Unzipped on a local disk ........ <path / OneDrive warning>
PASS/WARN/FAIL  Boilerplate files present ....... <missing files if any>
PASS/WARN/FAIL  vendor/sql-asm.js intact ........ <size, checksum>
PASS/WARN/FAIL  Browser policies ................ <blocking policies found, if any>
PASS/WARN/FAIL  App opens on the start screen .. <browser used, what was seen>
PASS/WARN/FAIL  Data survives a reload (optional) <result or "not tested">

Agent can read/edit project files: yes/no
Agent commands ran without per-command approval: yes/no (Codex "Approve for me" / Claude Code permission mode)

Restrictions detected:
- None / exact blockers

What Capgemini IT should allow:
- None / for example:
  - Microsoft Edge or Google Chrome installed
  - Extract the zip to a local folder (not inside the zip, not a network drive; avoid OneDrive)
  - Allow site data (IndexedDB / localStorage) for file:// pages in Edge/Chrome
  - Allow JavaScript on file:// pages
  - Allow downloads from the browser (Export) and the file picker (Import)
  - Exclude the project folder from antivirus quarantine if vendor/sql-asm.js was removed or changed
  - Let the coding agent run PowerShell / terminal commands without approving each one

OVERALL: PASS - ready for the lab / FAIL - not ready yet
```

`OVERALL` is `PASS` when there is no `FAIL` line (WARN lines are allowed). Any `FAIL` → `FAIL`.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with no Node, npm, Python or server. Whatever this skill asks, **never**:
- run `npm`, `npx`, `node`, `pip`, `python` or install anything;
- start a server or use `localhost`;
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
