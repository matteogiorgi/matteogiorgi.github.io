import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";

mermaid.initialize({ startOnLoad: false });

window.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll("pre > code.language-mermaid").forEach((code) => {
        const div = document.createElement("div");
        div.className = "mermaid";
        div.textContent = code.textContent;
        code.parentElement.replaceWith(div);
    });
    mermaid.run();
});
