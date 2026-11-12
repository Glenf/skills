# HTML views

One self-contained file. The diagrams carry the point; prose names it and
cites the proof. If a diagram needs a paragraph to be understood, redraw the
diagram.

## Scaffold

Tailwind for layout and Mermaid for graph-shaped diagrams, both from a CDN.
No other scripts, no app code, no interactivity beyond Mermaid's rendering.
Load Mermaid only when a view uses it.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{{topic}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral" });
    </script>
    <style>
      /* only what Tailwind does not cover: seam lines, arrow heads */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-4 sm:px-6 py-12 space-y-12">
      <header><!-- topic, date, legend --></header>
      <section><!-- one <article> per point --></section>
      <footer><!-- sources and what the views leave out --></footer>
    </main>
  </body>
</html>
```

## Header

The topic, the date, and a compact legend for every mark the diagrams use
(for example: solid box = module, dashed line = seam, red arrow = leak). No
introduction paragraph.

## One article per point

- **Title** — names the point ("Pricing leaks into order intake").
- **Files** — a monospaced list (`font-mono text-sm`).
- **The view** — the centrepiece. For a change, before and after side by
  side, stacked on a phone.
- **Point** — one sentence.
- **Sources** — `file:line` ranges or the diff command, with `(inferred)`
  marks, in small monospaced text under the view.

## Diagram patterns

Pick the pattern that fits the point, and vary them; Mermaid for everything
looks generic.

- **Mermaid flowchart or sequence** — the workhorse for "X calls Y calls Z"
  and for round-trips ("before: six calls; after: one"). Wrap it in a card
  (`rounded-lg border border-slate-200 bg-white p-4`) and colour problem
  edges with `classDef`.
- **Hand-built boxes and arrows** — `<div>` boxes with inline SVG arrows over
  a relative container, for when Mermaid's layout fights you or a box needs
  visual weight (one thick deep module with faded internals).
- **Cross-section** — stacked horizontal bands (`h-12 border-l-4`) for the
  layers a call passes through. Before: many thin bands. After: one.
- **Mass diagram** — two rectangles per module, interface and implementation.
  Shallow: nearly the same height. Deep: short interface, tall
  implementation.
- **Collapse** — a tree of calls as nested boxes, then the same tree folded
  into one box with the internal calls faded.
- **Data flow** — source → transform → sink as a left-to-right band, with the
  data shape written on each arrow.

## Style

- Editorial, not a dashboard. Generous whitespace; `font-serif` headings work
  with stone and slate.
- One accent colour (emerald or indigo), red for problems, amber for warnings.
- A table wider than a phone scrolls inside its card (`overflow-x-auto`); the
  page itself never scrolls sideways.
- Diagrams about 320px tall, so before and after sit side by side without
  scrolling.
- Labels inside diagrams in `text-xs uppercase tracking-wider`, so they read
  as a schematic, not as UI.
- When the subject is the product's own UI, use the product's colours, type,
  and real labels instead.
- Plain words, short bullets. Use the project's `GLOSSARY.md` terms; for
  module design, use module, interface, seam, deep, and shallow.
