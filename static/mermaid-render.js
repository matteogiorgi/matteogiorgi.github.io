import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";

/* Mirrors the CSS custom properties in style.css (:root / :root[data-theme="dark"])
 * so diagrams sit in the site's own palette instead of Mermaid's default purple,
 * which has poor contrast against the dark background. Kept as literal hex values
 * rather than var(--x) references: Mermaid derives several colors (secondary/tertiary
 * shades, note colors, etc.) from these via real color math at render time, which
 * breaks if handed a CSS variable it can't parse as a color. */
const THEME_VARS = {
    light: {
        background:          "#fdfdfc",
        primaryColor:        "#f4f4f2",
        primaryBorderColor:  "#6a6a6a",
        primaryTextColor:    "#1a1a1a",
        lineColor:           "#6a6a6a",
        textColor:           "#1a1a1a",
        edgeLabelBackground: "#fdfdfc",
        clusterBkg:          "#f4f4f2",
        clusterBorder:       "#e3e3e0",
    },
    dark: {
        background:          "#16161a",
        primaryColor:        "#1c1c22",
        primaryBorderColor:  "#9a9a9a",
        primaryTextColor:    "#e6e6e6",
        lineColor:           "#9a9a9a",
        textColor:           "#e6e6e6",
        edgeLabelBackground: "#16161a",
        clusterBkg:          "#1c1c22",
        clusterBorder:       "#33333a",
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
