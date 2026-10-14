---
name: masterprompt
description: >
  Use this skill when the user types "/masterprompt", "$masterprompt",
  "master prompt", "make a master prompt", or asks for the master prompt
  maker for the Capgemini AI Product Crafting Lab.
---

# Master Prompt

Send the participant to the master prompt maker, then guide them to kick off
the app and paste their master prompt when ready.

The master prompt maker link is:
https://iq-capgemini-ai-crafting-lab.vercel.app/

Rules:
- Keep it short and non-technical.
- Try to open the link automatically in the participant's default browser.
- Always paste the clickable link in the chat too, even if the automatic open works.
- If the automatic open fails for any reason, do not show an error. Just give the link as the fallback and tell them to click it.

Workflow:
1. Try to open the master prompt maker automatically in the default browser:
   - On Windows: run `start "" "https://iq-capgemini-ai-crafting-lab.vercel.app/"`.
   - On Mac: run `open "https://iq-capgemini-ai-crafting-lab.vercel.app/"`.
   - If a browser/preview tool is available, you may use it to open the page instead.
2. Whether or not step 1 worked, always send the link in the chat:
   `Open the master prompt maker here: [Master prompt maker](https://iq-capgemini-ai-crafting-lab.vercel.app/)`
3. Tell the participant what to do next, in plain words:
   - Build their master prompt on that page.
   - Run `/kickoff` to open their app (nothing to install — it opens straight in the browser).
   - Then paste their master prompt here when they are ready, and you will build it for them.

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with no Node, npm, Python or server. Whatever this skill asks, **never**:
- run `npm`, `npx`, `node`, `pip`, `python` or install anything;
- start a server or use `localhost`;
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **if they work**. If one fails or you're stuck on it for more than 5 minutes, drop it and move on to another way; the app must never break or hang because of it.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
