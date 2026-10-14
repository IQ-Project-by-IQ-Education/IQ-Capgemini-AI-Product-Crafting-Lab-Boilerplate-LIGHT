---
name: kickoff
description: >
  Use this skill when the user types "/kickoff", "$kickoff", "kick off",
  "start the challenge", "start the app", or asks to launch the Capgemini AI
  Product Crafting Lab LIGHT starter. Names the app, opens index.html in the
  browser and confirms it shows "Items". Nothing is installed or started.
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
3. **Leave the example in place.** Do not touch `js/schema.js` or the `items` screens in `js/app.js` yet. They prove everything works and are the pattern you will copy.
4. **Open the app in the default browser:**
   - Windows: `Start-Process .\index.html` (PowerShell) or `start "" "index.html"` (Command Prompt).
   - macOS: `open index.html`.
   - If you have a browser tool (Codex in-app browser, Claude in Chrome, Playwright…), you may open `file:///<project folder>/index.html` there too.
5. **Confirm it shows "Items".** With a browser tool, read the page. Without one, ask: *"Do you see a page called Items with a New item button?"*
6. **Give them their link.** Build the full link from the folder path, e.g. `file:///C:/Lab/IQ-Capgemini-AI-Product-Crafting-Lab-Boilerplate-LIGHT/index.html`, and say:
   > Your app is open. This is your app's link: `<link>` — bookmark it (Ctrl+D) so you can always come back to it. Whenever I change something, just press F5 on that tab.
7. Then: *"Paste your master prompt here when you're ready and I'll build it."*

If the page does not show "Items":
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

Outside services (AI APIs, CDN libraries, web fonts) are allowed **if they work**. If one fails or you're stuck on it for more than 5 minutes, drop it and move on to another way; the app must never break or hang because of it.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
