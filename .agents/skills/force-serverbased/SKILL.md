---
name: force-serverbased
description: >
  TRAINER ONLY. Use when a trainer types "/force-serverbased", "$force-serverbased",
  or asks to force the app to run on localhost instead of from the file,
  optionally with a specific server (powershell, perl, node, python). Overrides
  the mode /kickoff chose: starts a server, switches lab-mode.txt to localhost
  mode and opens the app. Works on Mac and Windows.
---

# Force server-based (trainer override)

A trainer runs this when file mode is causing problems (the browser blocks saved data or features for `file://` pages), or to change which server runs the app. It puts the app on `http://localhost` through the launcher in `tools/`, which tries the lab's tiny servers (built-in parts only, nothing installed):
- Windows: PowerShell → Node → Python → Perl
- macOS: Perl → Node → Python

It overrides `/kickoff`'s decision and the "never switch modes" rule, because a trainer asked for it. The person talking to you is a trainer: you can be technical and brief. If the trainer names a server ("use node"), pass it to the launcher.

Workflow:
1. **Read `lab-mode.txt`** (if it exists) and note the current mode and link.
2. **Protect the data before switching.** The browser keeps saved data per address, so the app will look empty at the new address.
   - If the current mode is file **and the app already holds data**, ask the trainer to click **Export** in the app at the old link first. Wait for their OK.
   - If it was already localhost mode on the same port, or there's nothing worth keeping, skip this.
3. **Switch** with the launcher. It reuses the saved port if the app was already on localhost (same address = same data), else picks 8080, 8081 or 8082, tries the servers (~4 s each) and writes `lab-mode.txt`:
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\launch.ps1 server [powershell|node|python|perl] -Open`
   - macOS: `bash tools/launch.sh server [perl|node|python] --open`

   Success ends with `RESULT mode=localhost server=… url=http://localhost:<port>/` and opens it.
4. **Check it is still running** in a separate command (`… status` instead of `… server`): `running=yes`.
5. **Confirm** the app shows (browser tool, or ask the trainer).
6. **Restore the data** if it was exported in step 2: ask the trainer to click **Import** at the new link and pick the exported `.sqlite` file.
7. **Report** in two lines: `Mode: localhost` + the new link to bookmark. Remind them: after a computer restart, double-click `start-app.cmd` (Windows) or `start-app.command` (Mac), or ask the assistant.

**If it fails** (`RESULT error=no-server`): the launcher has already put back the previous mode. Don't loop and don't fall back silently: tell the trainer which servers were tried and why (the `TRIED` lines), and that the app stays in its previous mode. Suggest `/force-filebased` if the previous mode was also broken.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with nothing installed (optionally served on localhost by the lab's own tiny servers in `tools/`, decided once by `/kickoff` through `tools/launch.*`). Whatever this skill asks, **never**:
- install anything (`npm install`, `npx`, `pip install`, any package manager);
- start a server any other way than the launcher in `tools/` (no `npx serve`, `npm run dev`, `python -m http.server`, Live Server…);
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
