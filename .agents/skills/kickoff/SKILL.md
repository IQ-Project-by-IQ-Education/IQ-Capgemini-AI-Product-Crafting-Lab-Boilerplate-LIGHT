---
name: kickoff
description: >
  Use this skill when the user types "/kickoff", "$kickoff", "kick off",
  "start the challenge", "start the app", or asks to launch the Capgemini AI
  Product Crafting Lab LIGHT starter. Names the app, opens index.html in the
  browser and confirms it shows the "Build anything here" start screen.
  Nothing is installed or started.
---

# Kickoff

Launch the base app "our new way": the app is a single page that opens straight from the folder. **Nothing is installed and nothing is started.**

Rules:
- Do it yourself; keep the participant updated in one or two plain sentences.
- Never run npm, node, python, a server or any install. There is nothing to install.
- Do not create git commits.
- Do not ask the participant to troubleshoot. If something fails, fix it and retry.

Workflow:
1. **Confirm the folder.** `index.html`, `js/` and `vendor/sql-asm.js` are present.
2. **Name the app.** If the participant has already pasted their master prompt / spec, take the app's name from it and set it in `js/config.js`:
   `var APP_NAME = "Mini CRM";`
   If there is no spec yet, keep `"Lab App"` — it can be renamed later. (Renaming later starts a fresh, empty saved copy — fine at kickoff, avoid once they have real data.)
3. **Leave the starting screens in place.** The app opens on a blank canvas (Capgemini × IQ Project logos, "Build anything here"). Do not touch it, `js/schema.js` or the `items` example in `js/app.js` yet: the canvas is what the participant sees first, and `items` is the pattern you will copy.
4. **Open the app in the default browser:**
   - Windows: `Start-Process .\index.html` (PowerShell) or `start "" "index.html"` (Command Prompt).
   - macOS: `open index.html`.
   - If you have a browser tool (Codex in-app browser, Claude in Chrome, Playwright…), you may open `file:///<project folder>/index.html` there too.
5. **Confirm it shows the start screen.** With a browser tool, read the page. Without one, ask: *"Do you see the Capgemini and IQ Project logos with "Build anything here"?"*
6. **Give them their link.** Build the full link from the folder path, e.g. `file:///C:/Lab/IQ-Capgemini-AI-Product-Crafting-Lab-Boilerplate-LIGHT/index.html`, and say:
   > Your app is open. This is your app's link: `<link>` — bookmark it (Ctrl+D) so you can always come back to it. Whenever I change something, just press F5 on that tab.
7. Then: *"Paste your master prompt here when you're ready and I'll build it."*

If the page does not show the start screen:
- **Stays on "Loading…"** → first check `js/config.js` (a typo in the name line, e.g. a missing quote, blanks the start) and fix it. If the files are fine, it is the browser blocking saved data: try the other browser (Edge ↔ Chrome). If both fail, tell a helper: "This laptop's browser is blocking saved data for local pages" — and suggest running `/diagnose`.
- **Message "site storage is disabled"** → same as above: other browser, then a helper.
- **Opens as text or downloads the file** → open it explicitly in Edge/Chrome (right-click `index.html` → Open with → Microsoft Edge).
- **Missing files** → the zip was not fully extracted: ask a helper to extract it again (right-click → Extract All) to a local folder.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with no Node, npm, Python or server. Whatever this skill asks, **never**:
- run `npm`, `npx`, `node`, `pip`, `python` or install anything;
- start a server or use `localhost`;
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
