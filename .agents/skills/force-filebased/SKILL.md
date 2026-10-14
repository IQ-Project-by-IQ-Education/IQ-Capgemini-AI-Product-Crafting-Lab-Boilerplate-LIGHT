---
name: force-filebased
description: >
  TRAINER ONLY. Use when a trainer types "/force-filebased", "$force-filebased",
  or asks to force the app to run straight from the file (file:///.../index.html)
  instead of localhost. Overrides the mode /kickoff chose: stops the local
  server, switches lab-mode.txt to file mode and opens the app from the file.
  Works on Mac and Windows.
---

# Force file-based (trainer override)

A trainer runs this when the localhost mode chosen by `/kickoff` is causing problems (server window keeps closing, port conflicts, security software complaining…). It forces **file mode** for the rest of the lab. It overrides `/kickoff`'s decision and the "never switch modes" rule, because a trainer asked for it.

The person talking to you is a trainer: you can be technical and brief.

Workflow:
1. **Read `lab-mode.txt`** (if it exists) and note the current mode and link.
2. **Protect the data before switching.** The browser keeps saved data per address, so the app will look empty at the new address.
   - If the current mode is localhost **and the app already holds data**, ask the trainer to click **Export** in the app at the old link (`http://localhost:<port>/`) first, while the server still runs. Wait for their OK.
   - If it was already file mode, or there's nothing worth keeping, skip this.
3. **Switch** with the launcher (it stops any server and writes `lab-mode.txt`):
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\launch.ps1 file -Open`
   - macOS: `bash tools/launch.sh file --open`

   It ends with `RESULT mode=file url=file:///…/index.html` and opens that link.
4. If the launcher can't run (scripts blocked), stop the server by closing its window / process and write `lab-mode.txt` by hand: `mode=file` and `url=file:///<this folder, forward slashes>/index.html`, then open `index.html`.
5. **Confirm** the app shows (browser tool, or ask the trainer what they see).
6. **Restore the data** if it was exported in step 2: ask the trainer to click **Import** at the new link and pick the exported `.sqlite` file from Downloads.
7. **Report** in two lines: `Mode: file` + the new link to bookmark (the old bookmark no longer applies).

If the page doesn't load in file mode, follow the "does not show the start screen" checks in `.agents/skills/kickoff/SKILL.md`, then suggest `/diagnose`.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with nothing installed (optionally served on localhost by the lab's own tiny servers in `tools/`, decided once by `/kickoff` through `tools/launch.*`). Whatever this skill asks, **never**:
- install anything (`npm install`, `npx`, `pip install`, any package manager);
- start a server any other way than the launcher in `tools/` (no `npx serve`, `npm run dev`, `python -m http.server`, Live Server…);
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
