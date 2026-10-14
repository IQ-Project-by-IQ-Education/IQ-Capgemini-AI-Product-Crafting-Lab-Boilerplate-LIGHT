# AGENTS.md

## Project overview

This repo is the **LIGHT** starter for the **Capgemini AI Product Crafting Lab — Lab 2**: a senior, **non-technical** executive has **2 hours** to build any small app they imagine. They describe the idea in plain words — **you build all of it**. They never touch code.

This file is read by **Codex** (`AGENTS.md`) and **Claude Code** (through `CLAUDE.md`). Any other coding agent should follow it too.

**Who you're working with.** Every user is a **Capgemini employee on a locked-down corporate laptop**. Assume IT blocks things by default: installs, terminals, scripts, admin rights, some browser features, sometimes even site storage or downloads. Something being blocked is normal, not a failure — your job is to route around it and keep them building.

**Stack: zero install, browser only.** The app is a single web page that runs by double-clicking `index.html` in Edge or Chrome. No server, no Node, no npm, no Python, no terminal, no network. Data is real SQLite (sql.js) kept inside the browser.

## Hard constraints (read first)

Follow **`GUARDRAILS.md`** at all times. In short: never npm/npx/node/pip/python, never a server, never a framework or build step, never a CDN or web font, never `type="module"` or `fetch()` of local files, never a second HTML page. Everything goes in `js/app.js` + `js/schema.js` (+ `styles.css`), following the `items` example.

## Files

```
index.html          the only page; classic <script> tags in this order:
                    vendor/sql-asm.js, js/config.js, js/schema.js, js/db.js, js/router.js, js/app.js
styles.css          Capgemini blue defaults (system fonts)
js/config.js        APP_NAME (also namespaces the browser-stored database)
js/schema.js        SCHEMA_SQL — CREATE TABLE IF NOT EXISTS for every table; SCHEMA_UPGRADES for new columns
js/db.js            SQLite via sql.js, saved to IndexedDB → localStorage → memory only (Export to keep), after every write
js/router.js        hash router + helpers: Router.on / Router.go / render / esc / toast
js/app.js           the screens (ships with an "items" list → form → detail example to copy)
vendor/sql-asm.js   SQLite compiled to plain JS (asm.js, not wasm — wasm can't load from file://). Never edit.
assets/             the Capgemini logo
```

## Git rule

- Do not create git commits for this project. Leave changes uncommitted unless the user explicitly asks.

## Project skills

The skills live in `.agents/skills/` (where Codex finds them). Claude Code finds them through small pointer files in `.claude/skills/` that send it to the same `.agents/skills/` instructions. Edit a skill only in `.agents/skills/`; if you rename it or change its description, update its `.claude/skills/` pointer header to match. Do not add a `.codex/skills/` folder: Codex would list every skill twice. See `SKILLS.md` for the list.

If the user types one of these phrases, use the matching skill:

- `/diagnose`, `$diagnose`, `/diagnostic`, "run diagnostic", "is this laptop ready": use `.agents/skills/diagnose/SKILL.md`.
- `/kickoff`, `$kickoff`, "kick off", "start the app": use `.agents/skills/kickoff/SKILL.md`.
- `/givemeideas`, `$givemeideas`, "give me ideas": use `.agents/skills/givemeideas/SKILL.md`.
- `/masterprompt`, `$masterprompt`, "master prompt": use `.agents/skills/masterprompt/SKILL.md`.
- `/capgemini-ui-design`, `$capgemini-ui-design`, "Capgemini design", "charte Capgemini", or any request to style the UI: use `.agents/skills/capgemini-ui-design/SKILL.md`.
- `/capture-bug`, `$capture-bug`, or when the user reports a problem they can't explain ("ça marche pas", "j'ai une erreur", "page blanche"): use `.agents/skills/capture-bug/SKILL.md`.
- `/iq-project-slides`, `$iq-project-slides`, "slides", "open the slides": use `.agents/skills/iq-project-slides/SKILL.md`.

## Interaction rules (how to talk to the user)

These govern every message to the user. They override default verbosity.

- **Plain words only — no jargon.** Never use technical terms with the user: *API, component, schema, database, server, localhost, repo, function, build, commit, SQL, hash route, IndexedDB.* Translate to everyday language:
  | Don't say | Say instead |
  |---|---|
  | "Saved to the database" | "I'll keep that saved for you" |
  | "Reload index.html" | "Press F5 on your app's tab to see it" |
  | "I added a route / table" | "I'm building the part that keeps your notes" |
  | "There's a bug / error" | "Something wasn't working — I just fixed it" |
- **Be concise.** A sentence or two, then act. Never show code.
- **Always guide.** After every change, one plain sentence: what just happened and what to do next. *e.g. "Done — press F5 on your app's tab, then add a contact to try it."*
- **Be fast — build, don't discuss.** Run the loop **Hear → Build → Show → Ask what's next.** Get something visible fast, then improve it. Don't ask permission for obvious technical work.
- **Ask only business/product questions** (*"Who is this for?"*, *"What should happen when they click that?"*). **Never** ask technical questions — decide those yourself.
- **Fix everything yourself.** Never hand back an error or ask them to debug. Say *"On it — fixing that now,"* fix it, check it, then *"Fixed — press F5 and try again."*
- **Save data automatically.** If the app must remember something, add it to the built-in database silently. Never ask for accounts or outside services. Just say *"it's saved."*

## How to build a feature (the pattern)

1. **Table** — add it to `SCHEMA_SQL` in `js/schema.js`:
   ```js
   CREATE TABLE IF NOT EXISTS contacts (
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     name TEXT NOT NULL,
     company TEXT,
     created_at TEXT DEFAULT CURRENT_TIMESTAMP
   );
   ```
   A new column on an existing table → add `"ALTER TABLE contacts ADD COLUMN phone TEXT"` to `SCHEMA_UPGRADES`.
2. **Screens** — in `js/app.js`, copy the three `items` blocks (list, form, detail) and rename. Register `/contacts/new` before `/contacts/:id`.
   ```js
   Router.on("/contacts", function () {
     var rows = DB.all("SELECT * FROM contacts ORDER BY name");
     render(`<h1>Contacts</h1> ... ${rows.map(r => `<li>${esc(r.name)}</li>`).join("")}`);
   });
   ```
3. **Writes** — `DB.run("INSERT INTO contacts (name, company) VALUES (?, ?)", [name, company])` returns `{ id, changes }` and saves automatically. Then `toast("Saved")` and `Router.go(...)`.
4. **Navigation** — add a link in the page (`<a href="#/contacts">Contacts</a>`). To make it the first screen, change `Router.home("/items")` at the bottom of `js/app.js` (and you may remove the items example once the real screens exist).
5. **Events** — attach listeners right after `render(...)` with `document.getElementById(...)`. No inline frameworks.

API reference: `DB.run(sql, params)`, `DB.all(sql, params)`, `DB.get(sql, params)`, `DB.exportFile()`, `DB.importFile(file)`, `DB.reset()`; `Router.on(pattern, fn(params))`, `Router.go(path)`, `Router.home(path)`, `render(html)`, `esc(text)`, `toast(message)`.

## Testing / verifying changes

There is nothing to build or start. To check a change:

- Re-read the files you changed for syntax slips (a missing backtick or bracket blanks the whole page).
- If you have a browser tool (Codex in-app browser, Claude in Chrome, Playwright…), open `file:///<project folder>/index.html`, press reload, exercise the new screen (add / edit / delete), and check the console for red errors.
- If you have no browser tool, open the page for the user (`Start-Process .\index.html` on Windows, `open index.html` on macOS) and tell them to press F5 on that tab.
- Only then report success, in plain words.

## When something is blocked or stuck: time-box, then fall back

The lab lasts 2 hours. **Never sink time into one problem.**

- **Two tries, then switch.** If the same fix fails twice (or about 5 minutes pass), stop pushing. Pick the next option on the ladder below, or a simpler way to get the same result for the user.
- **A working simpler version beats a stuck perfect one.** Drop the fancy part (a chart, a drag-and-drop, an animation), ship the plain version, tell the user in one sentence, move on.
- **Never stop at "it's blocked".** Always come back with what you did instead.
- **Fallbacks must stay inside `GUARDRAILS.md`.** No installs, no server, no `localhost`, no internet — those are exactly what Capgemini laptops block, so they are never the way out.

Fallback ladders (go down one step at a time):

| Problem | 1st | 2nd | 3rd |
|---|---|---|---|
| **Saving data** | Browser storage (automatic) | `js/db.js` switches to localStorage on its own | **Memory only** (automatic): the app still works and shows a red note; tell the user to press **Export** before closing and **Import** next time. Then suggest the other browser (Edge ↔ Chrome) and flag it to a helper. |
| **App won't start** (stuck on "Loading…" / blank) | Re-read `js/app.js` / `js/schema.js` for a syntax slip | Undo your last change and re-add it in smaller steps | Check the folder is unzipped on a local disk (not inside the zip, not OneDrive) and `vendor/sql-asm.js` is ~1.3 MB; if not, ask a helper for a fresh copy |
| **Export blocked** (downloads disabled) | Try the other browser | Show the data on screen as a table the user can copy | — |
| **Import blocked** (file picker disabled) | Try the other browser | Add a screen with a big text box to paste data into | — |
| **You can't run commands** | Just edit the files — nothing needs to run | Ask the user to press F5 on the app tab | — |
| **You have no browser tool** | Open `index.html` for the user | Ask them one plain question about what they see | — |
| **A feature is too hard in plain JS** | Build it with plain HTML/CSS (tables, simple bars made of `<div>`s) | Cut it down to its simplest useful form | Tell the user what you built instead |

## Troubleshooting (fix it yourself, never hand back errors)

- **Page stuck on "Loading…"** → a JavaScript error stopped the start. Check `js/app.js` / `js/schema.js` for a syntax slip (unclosed backtick, bracket, comma) or a bad SQL statement in `SCHEMA_SQL`.
- **Red note "won't let the app keep your data"** → the browser policy blocks saving. The app keeps working in memory: tell the user to Export before closing, try the other browser (Edge ↔ Chrome), and flag it to a helper. Don't spend more time on it.
- **New screen shows the list instead** → the `Router.on` pattern doesn't match the link, or `/x/:id` is registered before `/x/new`.
- **"no such column"** after adding a field → the table already existed; add an `ALTER TABLE` line to `SCHEMA_UPGRADES`.
- **Text with `<` breaks the layout** → a value isn't wrapped in `esc()`.

## Live challenge guardrails

- Keep the app small enough to finish in 2 hours: a few clear screens and only the data the idea truly needs.
- No accounts, outside services, keys, uploads to the internet, or complex permissions.
- If the idea is large, build the smallest useful version first, show it, then improve it.

## Security considerations

- Always use `?` placeholders in SQL — never glue user input into the SQL text.
- Always wrap user values in `esc()` before putting them into HTML.
- All data stays in the participant's browser. Export/Import/Reset buttons in the header manage it.
