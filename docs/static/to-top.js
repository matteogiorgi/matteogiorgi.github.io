// Back-to-top button, shared by the home page (haunt.scm) and the repo
// pages (_layouts/default.html). It sits in the bottom corner on the same
// side as the theme toggle and shows up only once the page has been
// scrolled past one screen, so short pages never get it. The markup is
// built here, so a page needs nothing but this script.
(function () {
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'top-toggle';
    btn.setAttribute('aria-label', 'Back to top');
    btn.setAttribute('aria-keyshortcuts', 'Home');
    btn.innerHTML =
        '<svg viewBox="0 0 16 16" width="16" height="16" aria-hidden="true">' +
        '<path d="M8 13.5V3M3.5 7.5 8 3l4.5 4.5" fill="none" stroke="currentColor"' +
        ' stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>' +
        '</svg>' +
        '<span class="btn-tip" aria-hidden="true">Back to top<kbd>Home</kbd></span>';
    // Macs have no Home key on most keyboards; Cmd-Up does the same.
    var platform = (navigator.userAgentData && navigator.userAgentData.platform) || navigator.platform;
    if (/mac|iphone|ipad/i.test(platform)) btn.querySelector('kbd').textContent = '⌘ ↑';
    document.body.appendChild(btn);

    var shown = false;
    function update() {
        var past = window.scrollY > window.innerHeight;
        if (past !== shown) {
            shown = past;
            btn.classList.toggle('is-shown', shown);
        }
    }
    window.addEventListener('scroll', update, { passive: true });
    window.addEventListener('resize', update);
    update();

    // Focus goes back to the top too, so that Tab continues from there
    // rather than from the button at the bottom (which is about to hide).
    var main = document.querySelector('main');
    if (main && !main.hasAttribute('tabindex')) main.setAttribute('tabindex', '-1');
    btn.addEventListener('click', function () {
        var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        window.scrollTo({ top: 0, behavior: reduce ? 'auto' : 'smooth' });
        if (main) main.focus({ preventScroll: true });
    });
})();
