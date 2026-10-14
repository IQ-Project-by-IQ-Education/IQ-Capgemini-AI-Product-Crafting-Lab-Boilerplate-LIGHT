---
name: launch-filebased
description: >
  TRAINER ONLY. Use when a trainer types "/launch-filebased", "$launch-filebased",
  or asks to force the app to run straight from the file (file:///.../index.html)
  instead of localhost. Overrides the mode /kickoff chose: stops the local
  server, switches lab-mode.txt to file mode and opens the app from the file.
---

# Launch file-based (trainer override)

A trainer runs this when the localhost mode chosen by `/kickoff` is causing problems (server window keeps closing, port conflicts, security software complaining…). It forces **file mode** for the rest of the lab. It overrides `/kickoff`'s decision and the "never switch modes" rule, because a trainer asked for it.

The person talking to you is a trainer: you can be technical and brief.

Workflow:
1. **Read `lab-mode.txt`** (if it exists) and note the current mode and link.
2. **Protect the data before switching.** The browser keeps saved data per address, so the app will look empty at the new address.
   - If the current mode is localhost **and the app already holds data**, ask the trainer to click **Export** in the app at the old link (`http://localhost:<port>/`) first, while the server still runs. Wait for their OK.
   - If it was already file mode, or there's nothing worth keeping, skip this.
3. **Stop the local server** (Windows):
   `Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object CommandLine -like '*serve.ps1*' | ForEach-Object { Stop-Process -Id $_.ProcessId }`
4. **Write `lab-mode.txt`** with this folder's real path (forward slashes):
   ```
   mode=file
   url=file:///C:/Lab/IQ-Capgemini-AI-Product-Crafting-Lab-Boilerplate-LIGHT/index.html
   ```
5. **Open the app:** Windows `Start-Process .\index.html`; macOS `open index.html` (or a browser tool on the `file:///` link).
6. **Confirm** the app shows (browser tool, or ask the trainer what they see).
7. **Restore the data** if it was exported in step 2: ask the trainer to click **Import** at the new link and pick the exported `.sqlite` file from Downloads.
8. **Report** in two lines: `Mode: file` + the new link to bookmark (the old bookmark no longer applies).

If the page doesn't load in file mode, follow the "does not show the start screen" checks in `.agents/skills/kickoff/SKILL.md`, then suggest `/diagnose`.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with no Node, npm or Python (optionally served on localhost by the built-in `tools/serve.ps1`, decided once by `/kickoff`). Whatever this skill asks, **never**:
- run `npm`, `npx`, `node`, `pip`, `python` or install anything;
- start any server other than the built-in `tools/serve.ps1` (no Node, Python or other local servers);
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
