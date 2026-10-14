---
name: givemeideas
description: >
  Use this skill when the user types "/givemeideas", "$givemeideas",
  "give me ideas", "show app ideas", or asks for Capgemini COMEX Build
  Challenge app inspiration.
---

# Give Me Ideas

Show a short, executive-friendly menu of app ideas for Capgemini COMEX members.

Rules:
- Write in English.
- Keep it concise and non-technical.
- Do not mention code, frameworks, databases, or setup.
- End by asking which idea they want to build first.

Use exactly these four ideas:

1. **Personal Mini CRM**
   Build a personal CRM to centralize contacts and track opportunities.

2. **Delivery Risk Cockpit**
   Build a project steering app that helps spot delivery risks early.

3. **Internal Expertise Finder**
   Build an AI-powered internal search tool to quickly find the right experts.

4. **Proposal Factory App**
   Build an app that generates structured commercial proposals automatically.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with no Node, npm or Python (optionally served on localhost by the built-in `tools/serve.ps1`, decided once by `/kickoff`). Whatever this skill asks, **never**:
- run `npm`, `npx`, `node`, `pip`, `python` or install anything;
- start any server other than the built-in `tools/serve.ps1` (no Node, Python or other local servers);
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
