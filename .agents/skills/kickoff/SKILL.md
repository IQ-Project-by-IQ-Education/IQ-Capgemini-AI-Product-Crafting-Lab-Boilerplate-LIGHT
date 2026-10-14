---
name: kickoff
description: >
  Use this skill when the user types "/kickoff", "$kickoff", "kick off",
  "start the challenge", "start the app", or asks to launch the Capgemini AI
  Product Crafting Lab LIGHT starter. Names the app, decides once whether the
  app runs on localhost (tries PowerShell / Perl, Node, Python servers with
  short timeouts) or straight from the file, opens it and confirms the
  "Build anything here" start screen. Nothing is installed. Mac and Windows.
---

# Kickoff

Launch the base app "our new way": a single page, nothing to install. **This is the one moment where you decide how the app runs on this laptop**, for the rest of the lab:
- **Localhost mode** (preferred when it works): a tiny server from the `tools/` folder serves the app on `http://localhost:<port>/`, this computer only. The launcher tries, in order, with about 4 seconds each:
  - Windows: PowerShell (built in) → Node → Python → Perl
  - macOS: Perl (built in) → Node → Python
  Each server uses only its language's built-in parts: nothing is ever installed (no `npm install`, no `pip install`). Placeholder Pythons that would pop up an install prompt are skipped.
- **File mode** (always works): if no server answers, the browser opens `index.html` straight from the folder (`file:///…`).

The launcher (`tools/launch.ps1` on Windows, `tools/launch.sh` on macOS) does all of this and saves the choice in `lab-mode.txt`. It is never changed afterwards (only a trainer can override it, with `/force-filebased` or `/force-serverbased`): the browser keeps the app's saved data separately for each address, so switching later would make the data look gone.

Rules:
- Do it yourself; keep the participant updated in one or two plain sentences.
- Never install anything (no npm/pip install). Only start servers through the launcher in `tools/`.
- Do not create git commits.
- Do not ask the participant to troubleshoot. If something fails, fix it and retry.

Workflow:
1. **Confirm the folder.** `index.html`, `js/` and `vendor/sql-asm.js` are present.
2. **Name the app.** If the participant has already pasted their master prompt / spec, take the app's name from it and set it in `js/config.js`:
   `var APP_NAME = "Mini CRM";`
   If there is no spec yet, keep `"Lab App"` — it can be renamed later. (Renaming later starts a fresh, empty saved copy — fine at kickoff, avoid once they have real data.)
3. **Leave the starting screens in place.** The app opens on a blank canvas (Capgemini × IQ Project logos, "Build anything here"). Do not touch it, `js/schema.js` or the `items` example in `js/app.js` yet: the canvas is what the participant sees first, and `items` is the pattern you will copy.
4. **Run the launcher** from the project folder (it reuses `lab-mode.txt` if it already exists):
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\launch.ps1 auto`
   - macOS: `bash tools/launch.sh auto`

   It takes a few seconds and ends with one line: `RESULT mode=localhost server=… url=http://localhost:8080/` or `RESULT mode=file url=file:///…/index.html`. Lines starting with `TRIED` say which servers were skipped; don't mention them to the participant.
   If the launcher itself can't run (scripts blocked by policy), write `lab-mode.txt` by hand in file mode (`mode=file` and `url=file:///<this folder, forward slashes>/index.html`) and continue.
5. **Check it is still running** in a *separate* command (servers must survive after the launcher's command ends):
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\launch.ps1 status`; macOS: `bash tools/launch.sh status`.
   - `running=no` → run `restart` once (same command, `restart` instead of `status`). Still no → switch to file mode with `file` and continue.
6. **Open the app and confirm the start screen.** Open the `url` (Windows `Start-Process "<url>"`, macOS `open "<url>"`, or a browser tool), then read the page or ask: *"Do you see the Capgemini and IQ Project logos with "Build anything here"?"*
   In localhost mode, if it doesn't show after one reload: run the launcher with `file`, open the new link, and continue. Never spend more than 2 minutes on this whole decision.
7. **Give them their link** (the `url` from `lab-mode.txt`) and say:
   > Your app is open. This is your app's link: `<link>` — bookmark it (Ctrl+D) so you can always come back to it. Whenever I change something, just press F5 on that tab.

   In localhost mode, add one sentence: *"Your app runs quietly in the background. If you restart your computer, double-click **start-app** in the project folder (or just ask me)."*
8. Then: *"Paste your master prompt here when you're ready and I'll build it."*

If the page does not show the start screen (file mode, or after falling back to it):
- **Stays on "Loading…"** → first check `js/config.js` (a typo in the name line, e.g. a missing quote, blanks the start) and fix it. If the files are fine, it is the browser blocking saved data: try the other browser (Edge ↔ Chrome). If both fail, tell a helper: "This laptop's browser is blocking saved data for local pages" — and suggest running `/diagnose`.
- **Message "site storage is disabled"** → same as above: other browser, then a helper.
- **Opens as text or downloads the file** → open it explicitly in Edge/Chrome (right-click `index.html` → Open with → Microsoft Edge).
- **Missing files** → the zip was not fully extracted: ask a helper to extract it again (right-click → Extract All) to a local folder.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with nothing installed (optionally served on localhost by the lab's own tiny servers in `tools/`, decided once by `/kickoff` through `tools/launch.*`). Whatever this skill asks, **never**:
- install anything (`npm install`, `npx`, `pip install`, any package manager);
- start a server any other way than the launcher in `tools/` (no `npx serve`, `npm run dev`, `python -m http.server`, Live Server…);
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
