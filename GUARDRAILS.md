# Hard constraints — LIGHT lab stack

Capgemini lab laptops block Node, npm and Python. The app is **one web page that runs by
double-clicking `index.html`** in Edge or Chrome. Every agent (Codex, Claude Code or any other)
must respect these rules for the whole lab, even if a "better" option seems obvious.

**Never**
- Never run or suggest `npm`, `npx`, `node`, `pip`, `python`, `yarn`, `pnpm`, or any install.
- Never start a server (`localhost`, `http-server`, `python -m http.server`, Live Server…).
- Never add a framework or build step (React, Vue, Next, Vite, Tailwind, TypeScript, JSX…).
- Never add a `<script>` or `<link>` pointing to the internet (CDN, Google Fonts, unpkg, jsdelivr…).
- Never use `type="module"`, `import`/`export`, or `fetch()` of local files — they fail on `file://`.
- Never create a second HTML page. New screens are hash routes (`#/thing`) in `js/app.js`.
- Never call an outside service or API, and never ask for accounts or keys.

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
