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

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with no Node, npm, Python, server or internet. Whatever this skill asks, **never**:
- run `npm`, `npx`, `node`, `pip`, `python` or install anything;
- start a server or use `localhost`;
- add a framework, build step, CDN `<script>`, or web font;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
