# Hard constraints — LIGHT lab stack

Capgemini lab laptops block Node, npm and Python. The app is **one web page that runs by
double-clicking `index.html`** in Edge or Chrome. Every agent (Codex, Claude Code or any other)
must respect these rules for the whole lab, even if a "better" option seems obvious.

**Never**
- Never run or suggest `npm`, `npx`, `node`, `pip`, `python`, `yarn`, `pnpm`, or any install.
- Never start a server (`localhost`, `http-server`, `python -m http.server`, Live Server…).
- Never add a framework or build step (React, Vue, Next, Vite, Tailwind, TypeScript, JSX…).
- Never use `type="module"`, `import`/`export`, or `fetch()` of local files — they fail on `file://`.
- Never create a second HTML page. New screens are hash routes (`#/thing`) in `js/app.js`.

**Always**
- Screens and behavior go in `js/app.js`, copying the `items` example (list → form → detail).
- Tables go in `js/schema.js` as `CREATE TABLE IF NOT EXISTS`; new columns go in `SCHEMA_UPGRADES`.
- Data access only through `DB.run` / `DB.all` / `DB.get`, with `?` placeholders for user input.
- Show screens with `render(html)`, wrap every user value in `esc()`, confirm actions with `toast()`.
- Styling goes in `styles.css` (Capgemini blue tokens, system fonts).
- `vendor/sql-asm.js` is never edited, replaced or swapped for the `.wasm` build.
- The script order in `index.html` stays: `vendor/sql-asm.js`, `js/config.js`, `js/schema.js`,
  `js/db.js`, `js/router.js`, `js/app.js`. A new script file is a last resort; if you add one,
  it is a classic script placed before `js/app.js`.
- To check a change: reload `index.html` in the browser (F5). There is nothing to build or restart.

**Outside services are allowed — only if they work** (HARD RULE: 5 minutes, then base boilerplate)
- The app may use online services and resources: an AI API (OpenAI…), a public data API, a library
  or web font loaded from a CDN (`<script src="https://cdn.jsdelivr.net/…">`), Microsoft 365 data.
- **HARD RULE — 5 minutes, then back to the base boilerplate.** If an outside service doesn't work
  on this laptop (blocked, CORS error, no key, no answer) within 5 minutes of starting on it:
  1. stop, no more retries or debugging;
  2. remove every trace of it (its `<script>`/`<link>` tag, its calls, its key line);
  3. build that feature with the base boilerplate only: `index.html` + `js/` + the built-in
     database, plain HTML/JS, local data;
  4. do not try a different outside service instead.
  No exceptions. The base boilerplate is always the fallback.
- **Optional, never load-bearing:** the app must still open and its saved data still work if the
  service is down. Every outside call gets a timeout (about 20 s) and a plain message on failure
  ("AI is unavailable right now"), never an endless spinner. A CDN library is loaded with a classic
  `<script>` tag before `js/app.js`, and the code checks it exists before using it.
- **Keys:** if a service needs a key, the user pastes the one they were given (e.g. from a trainer);
  keep it in `js/config.js` (e.g. `var OPENAI_API_KEY = "";`). Never invent a key or make the user sign
  up for something new during the lab.

**When something is blocked**
- Users are Capgemini staff on locked-down laptops: blocked features are expected.
- Two failed tries on the same problem → find another simple way that works inside the base
  boilerplate, quietly, without burdening the user (see `AGENTS.md`, "When something is blocked or stuck").
  Never break a rule above to get unstuck.
