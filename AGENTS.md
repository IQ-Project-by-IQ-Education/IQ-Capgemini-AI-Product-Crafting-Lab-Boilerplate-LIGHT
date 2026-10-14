# AGENTS.md

## Project overview

This repo is the **LIGHT** starter for the **Capgemini AI Product Crafting Lab — Lab 2**: a senior, **non-technical** executive has **2 hours** to build any small app they imagine. They describe the idea in plain words — **you build all of it**. They never touch code.

This file is read by **Codex** (`AGENTS.md`) and **Claude Code** (through `CLAUDE.md`). Any other coding agent should follow it too.

**Who you're working with.** Every user is a **Capgemini employee on a locked-down corporate laptop**. Assume IT blocks things by default: installs, terminals, scripts, admin rights, some browser features, sometimes even site storage or downloads. Something being blocked is normal, not a failure — your job is to route around it and keep them building.

**Stack: zero install, browser only.** The app is a single web page that runs by double-clicking `index.html` in Edge or Chrome. No server, no Node, no npm, no Python, no terminal. Data is real SQLite (sql.js) kept inside the browser. Outside services (AI APIs, online libraries) are allowed **when they work** (see *Outside services*).

## Hard constraints (read first)

Follow **`GUARDRAILS.md`** at all times. In short: never npm/npx/node/pip/python, never a server, never a framework or build step, never `type="module"` or `fetch()` of local files, never a second HTML page. Outside services only if they work; **hard rule: if one doesn't work within 5 minutes, remove it and stick to the base boilerplate.** Everything goes in `js/app.js` + `js/schema.js` (+ `styles.css`), following the `items` example.

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
- **Save data automatically.** If the app must remember something, add it to the built-in database silently. Never ask them to create accounts. Just say *"it's saved."*

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

## When something is blocked or stuck: time-box, then find another way

The lab lasts 2 hours. **Never sink time into one problem.**

- **Two tries or 5 minutes, then switch.** If the same fix fails twice, or you've been stuck on something for more than 5 minutes, stop pushing and find a different way to get the same result. Don't keep retrying the same idea.
- **There is no fixed recipe.** Use your judgment: whatever is simplest and actually works on this laptop is the right answer. The examples below are ideas, not steps to follow in order.
- **Keep it invisible to the user.** Solving blocks is your job, not theirs. Don't explain what failed, don't hand them steps, don't ask them to change settings. They should only see their app keep working. Involve them only if there is truly no other way (e.g. pressing F5, or saying what they see on screen).
- **A working simpler version beats a stuck perfect one.** If a part is too hard, build a plain version that does the job and mention it in one sentence.
- **Stay inside `GUARDRAILS.md`.** No installs, no server, no `localhost`: those are exactly what Capgemini laptops block, so they are never the way out. An outside service is allowed **only if it works**; if it doesn't within 5 minutes, remove it and stick to the base boilerplate (hard rule, see *Outside services*).

Ideas that often work:
- **Saving is blocked** → `js/db.js` already handles it by itself (browser storage, then a simpler storage, then memory only with a red note asking to Export before closing, the only case where the user must act). Don't spend time on it; keep building.
- **App won't start** → look for a syntax slip in what you just changed, or undo it and re-add it in smaller steps.
- **A download or file picker is blocked** → show the data on screen, or let the user paste it into a text box.
- **You can't run commands or have no browser tool** → nothing needs to run: edit the files and have the user press F5.
- **A feature is hard in plain JS** → plain HTML/CSS usually does it (tables, bars made of `<div>`s, simple lists).

## Outside services (allowed if they work)

The app can use online services: an AI API (e.g. OpenAI with the key the participant got from a trainer), a public data API, Microsoft 365 data, or a library / web font from a CDN (`https://cdn.jsdelivr.net/npm/...`).

- **Try it once, quickly.** Wire it in, press F5, see if it answers. Corporate networks often block these (proxy, CORS error, blocked domain), that's normal.
- **HARD RULE — 5 minutes, then back to the base boilerplate. No exceptions.** If the service doesn't work within 5 minutes of starting on it:
  1. Stop. No more retries, no network debugging.
  2. Remove every trace of it: its `<script>` / `<link>` tag, its calls, its key line in `js/config.js`.
  3. Build that feature with the **base boilerplate only** (`index.html` + `js/` + the built-in database, plain HTML/JS, local data), or a simpler version of it.
  4. Do **not** try a different outside service instead.

  Tell the user in one plain sentence: *"That online service isn't reachable from this laptop, so I built it without it."*
- **Never let it break the app.** The app must still open and keep its saved data if the service is down. Give every call a timeout and a plain failure message:
  ```js
  function callOutside(url, options) {
    var ctrl = new AbortController();
    var timer = setTimeout(function () { ctrl.abort(); }, 20000);
    return fetch(url, Object.assign({}, options, { signal: ctrl.signal }))
      .finally(function () { clearTimeout(timer); });
  }
  // callOutside(...).then(...).catch(function () { toast("This feature is unavailable right now"); });
  ```
- **Libraries from a CDN** go in `index.html` as a classic `<script src="https://...">` placed before `js/app.js`. Check it loaded before using it (`if (window.Chart) { ... } else { /* plain fallback */ }`). No frameworks (React, Vue…) even from a CDN.
- **Keys** go in `js/config.js` (e.g. `var OPENAI_API_KEY = "";`) and the user pastes theirs. Never invent one, never ask them to sign up for something new.

## Troubleshooting (fix it yourself, never hand back errors)

- **Page stuck on "Loading…"** → a JavaScript error stopped the start. Check `js/app.js` / `js/schema.js` for a syntax slip (unclosed backtick, bracket, comma) or a bad SQL statement in `SCHEMA_SQL`.
- **Red note "won't let the app keep your data"** → the browser policy blocks saving. The app keeps working in memory and the note already tells the user to Export before closing. Don't spend more time on it.
- **New screen shows the list instead** → the `Router.on` pattern doesn't match the link, or `/x/:id` is registered before `/x/new`.
- **"no such column"** after adding a field → the table already existed; add an `ALTER TABLE` line to `SCHEMA_UPGRADES`.
- **Text with `<` breaks the layout** → a value isn't wrapped in `esc()`.

## Live challenge guardrails

- Keep the app small enough to finish in 2 hours: a few clear screens and only the data the idea truly needs.
- No new accounts or complex permissions. Outside services only if they work; after 5 minutes without success, back to the base boilerplate (hard rule).
- If the idea is large, build the smallest useful version first, show it, then improve it.

## Security considerations

- Always use `?` placeholders in SQL — never glue user input into the SQL text.
- Always wrap user values in `esc()` before putting them into HTML.
- The app's saved data stays in the participant's browser. Export/Import/Reset buttons in the header manage it. Only send to an outside service what the feature needs.
- A key in `js/config.js` is visible to anyone who gets the folder: tell the user not to share the folder or the zip once a key is in it.
