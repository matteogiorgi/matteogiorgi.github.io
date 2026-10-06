// Code blocks of the Markdown pages: shared by the repo pages
// (_layouts/default.html) and this repo's own Geopage (haunt.scm). Each
// <pre> inside .markdown-body gets wrapped in .code-block-wrap, with a
// toolbar overlaid on its top-right corner: the language label, read off
// the nearest language-* class (as Rouge/kramdown emit it), and a button
// that copies the code to the clipboard. Styled in style.css.
(function () {
    document.querySelectorAll('.markdown-body pre').forEach(function (pre) {
        var code = pre.querySelector('code');
        if (!code) return;
        var wrap = document.createElement('div');
        wrap.className = 'code-block-wrap';
        pre.parentNode.insertBefore(wrap, pre);
        wrap.appendChild(pre);
        var toolbar = document.createElement('div');
        toolbar.className = 'code-toolbar';
        var langWrapper = pre.closest('[class*="language-"]');
        var langMatch = langWrapper && langWrapper.className.match(/language-(\S+)/);
        if (langMatch && langMatch[1] !== 'plaintext') {
            var label = document.createElement('span');
            label.className = 'code-lang';
            label.textContent = langMatch[1];
            toolbar.appendChild(label);
        }
        var btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'copy-btn';
        btn.setAttribute('aria-label', 'Copy code');
        btn.innerHTML =
            '<svg class="icon-copy" viewBox="0 0 16 16" width="14" height="14" aria-hidden="true">' +
            '<path fill="currentColor" d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 0 1 0 1.5h-1.5a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-1.5a.75.75 0 0 1 1.5 0v1.5A1.75 1.75 0 0 1 9.25 16h-7.5A1.75 1.75 0 0 1 0 14.25Z"/>' +
            '<path fill="currentColor" d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0 1 14.25 11h-7.5A1.75 1.75 0 0 1 5 9.25Zm1.75-.25a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-7.5a.25.25 0 0 0-.25-.25Z"/>' +
            '</svg>' +
            '<svg class="icon-check" viewBox="0 0 16 16" width="14" height="14" aria-hidden="true">' +
            '<path fill="currentColor" d="M13.78 4.22a.75.75 0 0 1 0 1.06l-7.25 7.25a.75.75 0 0 1-1.06 0L2.22 9.28a.75.75 0 0 1 1.06-1.06L6 10.94l6.72-6.72a.75.75 0 0 1 1.06 0Z"/>' +
            '</svg>';
        btn.addEventListener('click', function () {
            navigator.clipboard.writeText(code.textContent).then(function () {
                btn.classList.add('copied');
                btn.setAttribute('aria-label', 'Copied!');
                setTimeout(function () {
                    btn.classList.remove('copied');
                    btn.setAttribute('aria-label', 'Copy code');
                }, 1500);
            }).catch(function () {});
        });
        toolbar.appendChild(btn);
        wrap.appendChild(toolbar);
    });
})();
