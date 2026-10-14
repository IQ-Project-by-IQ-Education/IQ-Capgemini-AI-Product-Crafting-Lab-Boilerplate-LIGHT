---
name: kickoff
description: >
  Use this skill when the user types "/kickoff", "$kickoff", "kick off",
  "start the challenge", "start the app", or asks to launch the Capgemini AI
  Product Crafting Lab LIGHT starter. Names the app, decides once whether the
  app runs on localhost (built-in Windows server, optional) or straight from
  the file, opens it and confirms the "Build anything here" start screen.
  Nothing is installed.
---

# Kickoff

Launch the base app "our new way": a single page, nothing to install. **This is the one moment where you decide how the app runs on this laptop**, for the rest of the lab:
- **Localhost mode** (preferred when it works): the built-in Windows server `tools/serve.ps1` serves the folder on `http://localhost:<port>/`. No Node, no install, no admin rights, this computer only.
- **File mode** (always works): the browser opens `index.html` straight from the folder (`file:///…`).

The choice is saved in `lab-mode.txt` and never changed afterwards: the browser keeps the app's saved data separately for each address, so switching later would make the data look gone.

Rules:
- Do it yourself; keep the participant updated in one or two plain sentences.
- Never run npm, node, python or any install. The only server allowed is `tools/serve.ps1`.
- Do not create git commits.
- Do not ask the participant to troubleshoot. If something fails, fix it and retry.

Workflow:
1. **Confirm the folder.** `index.html`, `js/` and `vendor/sql-asm.js` are present.
2. **Name the app.** If the participant has already pasted their master prompt / spec, take the app's name from it and set it in `js/config.js`:
   `var APP_NAME = "Mini CRM";`
   If there is no spec yet, keep `"Lab App"` — it can be renamed later. (Renaming later starts a fresh, empty saved copy — fine at kickoff, avoid once they have real data.)
3. **Leave the starting screens in place.** The app opens on a blank canvas (Capgemini × IQ Project logos, "Build anything here"). Do not touch it, `js/schema.js` or the `items` example in `js/app.js` yet: the canvas is what the participant sees first, and `items` is the pattern you will copy.
4. **If `lab-mode.txt` already exists**, the decision was made before: don't redo it. Use its mode and link (in localhost mode, if the link doesn't answer, restart the server as in 5b), then go to step 7.
5. **Try localhost (Windows only, time-boxed to 2 minutes).** On macOS, skip straight to step 6.
   a. Pick a free port: `try { Invoke-WebRequest http://localhost:8080/ -UseBasicParsing -TimeoutSec 2 | Out-Null; "busy" } catch { "free" }`. If 8080 is busy, try 8081, then 8082. Use the chosen port everywhere below instead of 8080.
   b. Start the server in its own minimized window so it keeps running after your command ends:
      `Start-Process powershell -WindowStyle Minimized -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"$PWD\tools\serve.ps1",'-Port','8080','-NoOpen'`
   c. Within 15 seconds, check it answers: `(Invoke-WebRequest http://localhost:8080/vendor/sql-asm.js -UseBasicParsing).RawContentLength` must be about 1,355,169. Retry every 3 seconds.
   d. Open `http://localhost:8080/` in the default browser (`Start-Process http://localhost:8080/`) and confirm the start screen (browser tool, or ask *"Do you see the Capgemini and IQ Project logos with "Build anything here"?"*).
   e. **All good → localhost mode.** Write `lab-mode.txt`:
      ```
      mode=localhost
      url=http://localhost:8080/
      ```
   f. **Anything fails** (script refused, port busy three times, no answer in 15 s, page doesn't show) → stop the server you started (`Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object CommandLine -like '*serve.ps1*' | ForEach-Object { Stop-Process -Id $_.ProcessId }`), and go to step 6. Don't tell the participant what failed.
6. **File mode** (macOS, or localhost didn't work):
   - Open the app: Windows `Start-Process .\index.html`; macOS `open index.html`. A browser tool may open `file:///<project folder>/index.html` too.
   - Confirm the start screen (browser tool, or the same question as 5d).
   - Write `lab-mode.txt`:
     ```
     mode=file
     url=file:///C:/Lab/IQ-Capgemini-AI-Product-Crafting-Lab-Boilerplate-LIGHT/index.html
     ```
     (the real path of this folder, with forward slashes).
7. **Give them their link** (the `url` from `lab-mode.txt`) and say:
   > Your app is open. This is your app's link: `<link>` — bookmark it (Ctrl+D) so you can always come back to it. Whenever I change something, just press F5 on that tab.

   In localhost mode, add one sentence: *"A small minimized window keeps your app running, leave it open. If you restart your computer, double-click **start-app** in the project folder (or just ask me)."*
8. Then: *"Paste your master prompt here when you're ready and I'll build it."*

If the page does not show the start screen (file mode, or after falling back to it):
- **Stays on "Loading…"** → first check `js/config.js` (a typo in the name line, e.g. a missing quote, blanks the start) and fix it. If the files are fine, it is the browser blocking saved data: try the other browser (Edge ↔ Chrome). If both fail, tell a helper: "This laptop's browser is blocking saved data for local pages" — and suggest running `/diagnose`.
- **Message "site storage is disabled"** → same as above: other browser, then a helper.
- **Opens as text or downloads the file** → open it explicitly in Edge/Chrome (right-click `index.html` → Open with → Microsoft Edge).
- **Missing files** → the zip was not fully extracted: ask a helper to extract it again (right-click → Extract All) to a local folder.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with no Node, npm or Python (optionally served on localhost by the built-in `tools/serve.ps1`, decided once by `/kickoff`). Whatever this skill asks, **never**:
- run `npm`, `npx`, `node`, `pip`, `python` or install anything;
- start any server other than the built-in `tools/serve.ps1` (no Node, Python or other local servers);
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
