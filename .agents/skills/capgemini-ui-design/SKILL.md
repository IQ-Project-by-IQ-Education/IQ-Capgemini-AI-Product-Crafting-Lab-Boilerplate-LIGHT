---
name: capgemini-ui-design
description: Generate UI (web pages, components, dashboards, prototypes) that follow the Capgemini brand identity. Use this skill whenever the user asks to build, design, style, or mock up any interface "for Capgemini", "à la Capgemini", "charte Capgemini", or wants frontend output matching Capgemini's visual brand. Apply the tokens below to all HTML/CSS output.
---

# Capgemini UI Design

Apply Capgemini's brand identity to any UI. Use these tokens as the source of truth — do not improvise colors or fonts.

In this LIGHT starter the tokens are already defined at the top of `styles.css`. All styling goes in `styles.css`; all markup is plain HTML inside the `render(...)` templates in `js/app.js`. No React, no Tailwind, no CSS framework, no new stylesheet links.

## Color tokens

```css
:root {
  --cap-blue:        #0070AD; /* Primary — Capgemini Blue. Logo, headers, primary CTAs */
  --cap-vibrant:     #12ABDB; /* Secondary — Vibrant Blue. Accents, links, highlights */
  --cap-deep:        #003D5C; /* Dark blue for depth, footers, dark surfaces */
  --cap-ink:         #1A1A1A; /* Body text */
  --cap-gray:        #5A6872; /* Secondary text, captions */
  --cap-line:        #E3E8EC; /* Borders, dividers */
  --cap-surface:     #F5F7F9; /* Light section background */
  --cap-white:       #FFFFFF;
}
```

Brand gradient (logo spade, hero accents): `linear-gradient(135deg, #0070AD 0%, #12ABDB 100%)`.

Rules:
- Primary blue `#0070AD` dominates. Vibrant blue `#12ABDB` is an accent only — never the main surface color.
- White and light-gray surfaces; keep layouts clean and airy. Capgemini is a corporate consulting brand: restrained, trustworthy, not flashy.
- Reserve the gradient for hero areas and the logo, not for body buttons.

## Typography

- Brand font is **Ubuntu** (Capgemini's corporate typeface). You may load it from Google Fonts (`<link href="https://fonts.googleapis.com/css2?family=Ubuntu:wght@400;500;700&display=swap" rel="stylesheet">` in `index.html`) and put `'Ubuntu',` first in the `font-family` in `styles.css`. Keep the system stack after it (`"Segoe UI", -apple-system, BlinkMacSystemFont, Roboto, Helvetica, Arial, system-ui, sans-serif`) so the page still looks right if the font is blocked. If it doesn't load within 5 minutes, remove the link and keep the system fonts (hard rule).
- Headings: weight 700, tight line-height (1.15), color `--cap-deep` or `--cap-ink`.
- Body: weight 400, line-height 1.6, color `--cap-ink`.
- Generous letter-spacing avoided; keep neutral. Sentence case for headings, not ALL CAPS.

## Layout & components

- Generous whitespace, 8px spacing scale (8/16/24/32/48/64).
- Border radius: small and subtle — 4px to 8px. Avoid heavily rounded "playful" shapes.
- Shadows: soft and minimal, e.g. `0 2px 8px rgba(0,61,92,0.08)`.
- Buttons: primary = solid `--cap-blue`, white text; hover darkens to `--cap-deep`. Secondary = outlined `--cap-blue`.
- Links: `--cap-vibrant`, underline on hover.
- Cards: white surface, 1px `--cap-line` border or soft shadow, never both heavy.

## Logo

The official Capgemini logo (wordmark + blue spade) already lives in this repo at `assets/capgemini-logo.png` and is already shown in the header of `index.html`. The page opens from a file, so always use a **relative** path (no leading slash):

```html
<img src="assets/capgemini-logo.png" alt="Capgemini" />
```

- Always use this existing asset — never recreate, redraw, or fake the spade logo, and never recolor it.
- The logo sits well on white or light-gray surfaces. On the dark/gradient hero, place it inside a white pill/badge or use enough padding so the blue stays legible; do not place it directly on `--cap-blue`.
- Keep clear space around it (at least the height of the spade) and don't stretch — preserve its aspect ratio.
- If the file is ever missing, leave a placeholder area and tell the user to drop the official asset into `assets/capgemini-logo.png`.

## Quick CSS starter

```css
body { font-family: "Segoe UI", system-ui, sans-serif; color: var(--cap-ink); background: var(--cap-white); }
.btn-primary { background: var(--cap-blue); color: #fff; border: none; border-radius: 6px; padding: 12px 24px; font-weight: 500; }
.btn-primary:hover { background: var(--cap-deep); }
.hero { background: linear-gradient(135deg,#0070AD,#12ABDB); color:#fff; }
```

## Lab guardrails (always on — shared by every skill)

This lab runs on locked-down laptops: the app is one page opened from the folder (`index.html` in Edge/Chrome), with nothing installed (optionally served on localhost by the lab's own tiny servers in `tools/`, decided once by `/kickoff` through `tools/launch.*`). Whatever this skill asks, **never**:
- install anything (`npm install`, `npx`, `pip install`, any package manager);
- start a server any other way than the launcher in `tools/` (no `npx serve`, `npm run dev`, `python -m http.server`, Live Server…);
- add a framework or build step;
- use `type="module"`, `import`/`export`, or `fetch()` of local files;
- create another HTML page.

Outside services (AI APIs, CDN libraries, web fonts) are allowed **only if they work**. **Hard rule:** if one doesn't work within 5 minutes, stop, remove every trace of it and build with the base boilerplate only. Never try another outside service instead, and never let one break or hang the app.

App code goes only in `js/app.js`, `js/schema.js` and `styles.css`, following the `items` example and the `DB` / `Router` helpers. Full list: `GUARDRAILS.md` at the project root.
