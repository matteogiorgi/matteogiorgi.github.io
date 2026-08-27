import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";

/* Mirrors the CSS custom properties in style.css (:root / :root[data-theme="dark"])
 * so diagrams sit in the site's own palette instead of Mermaid's default purple,
 * which has poor contrast against the dark background. Kept as literal hex values
 * rather than var(--x) references: Mermaid derives several colors (secondary/tertiary
 * shades, note colors, etc.) from these via real color math at render time, which
 * breaks if handed a CSS variable it can't parse as a color.
 *
 * primaryColor/clusterBkg are --link blended over --bg at the same opacity as
 * --link-bg (10% light / 15% dark, 5% for the fainter cluster tint) -- pre-computed
 * here since fill/lineColor need solid colors, not the rgba() --link-bg itself.
 * primaryBorderColor/lineColor use --link at full strength so nodes and arrows
 * pick up the site's accent color instead of reading flat grayscale. */
/* Same monospace stack as `code` in style.css -- diagram labels are almost
 * always code (function calls, indices), so they read more consistently
 * next to inline code and code blocks than in Mermaid's default sans-serif. */
const FONT_FAMILY = '"Cascadia Code", ui-monospace, "SFMono-Regular", "DejaVu Sans Mono", Menlo, Consolas, monospace';

const THEME_VARS = {
    light: {
        background:          "#fdfdfc",
        primaryColor:        "#f5e4e3",
        primaryBorderColor:  "#a80000",
        primaryTextColor:    "#1a1a1a",
        lineColor:           "#a80000",
        textColor:           "#1a1a1a",
        edgeLabelBackground: "#fdfdfc",
        clusterBkg:          "#f9f0ef",
        clusterBorder:       "#e3e3e0",
        fontFamily:          FONT_FAMILY,
    },
    dark: {
        background:          "#16161a",
        primaryColor:        "#272e3b",
        primaryBorderColor:  "#8ab4f8",
        primaryTextColor:    "#e6e6e6",
        lineColor:           "#8ab4f8",
        textColor:           "#e6e6e6",
        edgeLabelBackground: "#16161a",
        clusterBkg:          "#1c1e25",
        clusterBorder:       "#33333a",
        fontFamily:          FONT_FAMILY,
    },
};

function currentTheme() {
    return document.documentElement.getAttribute("data-theme") === "dark" ? "dark" : "light";
}

/* Bumped on every renderAll() pass so re-renders (triggered by a theme
 * switch) never reuse a diagram id that's still live in the DOM from the
 * previous pass. */
let renderPass = 0;

async function renderAll() {
    mermaid.initialize({
        startOnLoad: false,
        theme: "base",
        themeVariables: THEME_VARS[currentTheme()],
    });

    const pass = renderPass++;
    const blocks = document.querySelectorAll(".mermaid[data-source]");
    for (const [i, div] of blocks.entries()) {
        const { svg } = await mermaid.render(`mermaid-diagram-${pass}-${i}`, div.dataset.source);
        div.innerHTML = svg;

        /* Mermaid ships width="100%" plus an inline max-width capped at the
         * diagram's natural pixel size, so it shrinks to fit a narrower
         * container but never grows past its own size in a wider one. That
         * asymmetry is exactly what we don't want: it leaves large diagrams
         * shrunk while small ones sit at natural size, so the same node
         * looks a different size depending on which diagram it's in. Pin
         * width/height to the viewBox's own pixel size instead, so every
         * diagram always renders 1:1 -- oversized ones then overflow into
         * the .mermaid container's horizontal scroll rather than shrinking. */
        const svgEl = div.querySelector("svg");
        const { width, height } = svgEl.viewBox.baseVal;
        svgEl.style.width = `${width}px`;
        svgEl.style.height = `${height}px`;
        svgEl.style.maxWidth = "none";
    }
}

window.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll("pre > code.language-mermaid").forEach((code) => {
        const div = document.createElement("div");
        div.className = "mermaid";
        div.dataset.source = code.textContent;
        code.parentElement.replaceWith(div);
    });
    renderAll();
});

/* haunt.scm's theme-toggle-script flips data-theme on <html>; re-render
 * every diagram from its stored source so it picks up the matching palette. */
new MutationObserver(renderAll).observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme"],
});
