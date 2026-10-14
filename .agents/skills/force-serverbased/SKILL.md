---
name: force-serverbased
description: >
  TRAINER ONLY. Use when a trainer types "/force-serverbased", "$force-serverbased",
  or asks to force the app to run on localhost with the built-in Windows server
  (tools/serve.ps1) instead of from the file. Overrides the mode /kickoff chose:
  starts the server, switches lab-mode.txt to localhost mode and opens the app.
---

# Force server-based (trainer override)

A trainer runs this when file mode is causing problems (the browser blocks saved data or features for `file://` pages) and they want the app on `http://localhost` through the built-in Windows server `tools/serve.ps1` (no Node, no install, no admin rights, this computer only). It overrides `/kickoff`'s decision and the "never switch modes" rule, because a trainer asked for it.

The person talking to you is a trainer: you can be technical and brief. **Windows only**: on macOS, say there is no built-in server and stop.

Workflow:
1. **Read `lab-mode.txt`** (if it exists) and note the current mode and link.
2. **Protect the data before switching.** The browser keeps saved data per address, so the app will look empty at the new address.
   - If the current mode is file **and the app already holds data**, ask the trainer to click **Export** in the app at the old link first. Wait for their OK.
   - If it was already localhost mode on the same port, or there's nothing worth keeping, skip this.
3. **Pick a port:** reuse the port from `lab-mode.txt` if it was already localhost, else 8080. Check it: `try { Invoke-WebRequest http://localhost:8080/ -UseBasicParsing -TimeoutSec 2 | Out-Null; "busy" } catch { "free" }`. If it answers and it is already this app, reuse it; if something else uses it, try 8081, then 8082.
4. **Start the server** in its own minimized window:
   `Start-Process powershell -WindowStyle Minimized -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"$PWD\tools\serve.ps1",'-Port','8080','-NoOpen'` (with the chosen port).
5. **Check it answers** within 15 seconds: `(Invoke-WebRequest http://localhost:8080/vendor/sql-asm.js -UseBasicParsing).RawContentLength` ≈ 1,355,169.
6. **Write `lab-mode.txt`**:
   ```
   mode=localhost
   url=http://localhost:8080/
   ```
7. **Open the app** (`Start-Process http://localhost:8080/`) and confirm it shows (browser tool, or ask the trainer).
8. **Restore the data** if it was exported in step 2: ask the trainer to click **Import** at the new link and pick the exported `.sqlite` file.
9. **Report** in two lines: `Mode: localhost` + the new link to bookmark. Remind them: the minimized "Lab app" window must stay open; after a restart, double-click `start-app.cmd`.

**If it fails** (script refused by policy, no port free, no answer in 15 s): don't loop and don't fall back silently. Leave `lab-mode.txt` as it was, stop any server you started, and tell the trainer exactly what failed (the error text) and that the app stays in its previous mode. Suggest `/force-filebased` if the previous mode was also broken.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with no Node, npm or Python (optionally served on localhost by the built-in `tools/serve.ps1`, decided once by `/kickoff`). Whatever this skill asks, **never**:
- run `npm`, `npx`, `node`, `pip`, `python` or install anything;
- start any server other than the built-in `tools/serve.ps1` (no Node, Python or other local servers);
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
