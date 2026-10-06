;;; haunt.scm --- geoteo.net
;;;
;;; Build a static site with Haunt (GNU Guile): the home page, plus this
;;; repo's own Geopage rendered from README.md.
;;;
;;;   haunt build            build into ./docs
;;;   haunt serve --watch    live preview on http://localhost:8080
;;;
;;; The site is a Scheme program: the pinned-repos section is generated
;;; from the `pinned-repos' data list below, so adding/reordering a project
;;; means editing data, not markup.

(use-modules (haunt site)
             (haunt page)
             (haunt html)
             (haunt builder assets)
             (ice-9 textual-ports)   ; get-string-all
             (srfi srfi-1)           ; filter-map
             (srfi srfi-9))          ; define-record-type


;;; --------------------------------------------------------------------
;;; Data model: one pinned repo = name + description + language + color
;;; --------------------------------------------------------------------

(define-record-type <repo>
  (make-repo* name description language color pages?)
  repo?
  (name        repo-name)         ; string, also the github.com/matteogiorgi/<name> slug
  (description repo-description)  ; string
  (language    repo-language)     ; string, GitHub's detected primary language
  (color       repo-color)        ; string, hex color for the language dot
  (pages?      repo-pages?))      ; #t: has a GitHub Pages site at geoteo.net/<name>/,
                                  ; or a string: the path of its Geopage instead

;; Most repos don't have a Pages site, so make that argument optional.
(define* (make-repo name description language color #:optional (pages? #f))
  (make-repo* name description language color pages?))

;; Where a repo's Geopage lives: geoteo.net/<name>/, unless the repo gives
;; its own path. This repo needs one: GitHub Pages redirects anything under
;; /matteogiorgi.github.io/ to the same path without that prefix.
(define (repo-pages-url r)
  (string-append "https://geoteo.net/"
                 (if (string? (repo-pages? r)) (repo-pages? r) (repo-name r))
                 "/"))

;; Render a single pinned repo as a card, GitHub-style: name, description,
;; language dot and name. Repos with a GitHub Pages site also get a
;; "Geopage" badge linking to it; repos without one get no badge at all.
(define (repo->sxml r)
  (let ((url (string-append "https://github.com/matteogiorgi/" (repo-name r))))
    `(li (@ (class "repo-card") (id ,(repo-name r)))
         (div (@ (class "repo-head"))
              (code (a (@ (href ,url)) ,(repo-name r)))
              ,@(if (repo-pages? r)
                  `((a (@ (class "badge badge-link")
                          (href ,(repo-pages-url r)))
                       "Geopage"))
                  '()))
         (p (@ (class "repo-desc")) ,(repo-description r))
         (div (@ (class "repo-lang"))
              (span (@ (class "lang-dot")
                       (style ,(string-append "background:" (repo-color r)))))
              ,(repo-language r)))))

(define pinned-repos
  (list
    (make-repo "floe"                   "X11 floating window manager"                  "C"                "#555555" #t)
    (make-repo "abulafia"               "Markov-Chain text generator"                  "C"                "#555555" #t)
    (make-repo "karp"                   "explicit NP-complete reductions"              "Go"               "#00add8" #t)
    (make-repo "octfmt"                 "GNU-Octave formatter"                         "Go"               "#00add8" #t)
    (make-repo "matescm"                "tiny implementation of Scheme"                "Scheme"           "#1e4aec" #t)
    (make-repo "octet"                  "Brainfuck interpreter"                        "Scheme"           "#1e4aec" #t)
    (make-repo "minilispr"              "minimal Lisp-to-R compiler"                   "R"                "#198ce7" #t)
    (make-repo "awkltb"                 "AWK life-table toolkit"                       "Awk"              "#c30e9b")
    (make-repo "heapx"                  "experimental C library for heaps"             "C"                "#555555")
    (make-repo "lapq"                   "learning-augmented priority queues"           "C"                "#555555")
    (make-repo "ulpe"                   "UNIX-like work environment"                   "Shell"            "#89e051" #t)
    (make-repo "nine"                   "plan9port zero-config setup"                  "Shell"            "#89e051" #t)
    (make-repo "second-brain"           "personal knowledge management system"         "Shell"            "#89e051" #t)
    (make-repo "dmenu"                  "patched fork of dmenu"                        "C"                "#555555")
    (make-repo "st"                     "patched fork of st"                           "C"                "#555555")
    (make-repo "slock"                  "patched fork of slock"                        "C"                "#555555")
    (make-repo "nn-option-pricing"      "feed-forward nn to approximate Black-Scholes" "Python"           "#3572a5" #t)
    (make-repo "toody"                  "project for my BSc thesis"                    "Python"           "#3572a5" #t)
    (make-repo "vim-notewiki"           "Vim plugin for note-taking"                   "Vim Script"       "#199f4b" #t)
    (make-repo "vim-startscreen"        "Vim plugin for splash-screen"                 "Vim Script"       "#199f4b" #t)
    (make-repo "funint"                 "functional interpreter"                       "OCaml"            "#ef7a08" #t)
    (make-repo "wiener"                 "Wiener's attack on RSA"                       "Wolfram Language" "#dd1100" #t)
    (make-repo "wordle"                 "Wordle implementation from NYT"               "Java"             "#b07219" #t)
    (make-repo "graph"                  "generic objects graph library"                "Java"             "#b07219" #t)
    (make-repo "membox"                 "object repository concurrent server"          "C"                "#555555" #t)
    (make-repo "sparse"                 "sparce matrices functions library"            "C"                "#555555" #t)
    (make-repo "asteroids"              "modern implementation of Asteroids"           "JavaScript"       "#f1e05a" #t)
    (make-repo "amele"                  "Streamlit condo-manager app"                  "Python"           "#3572a5" #t)
    (make-repo "cobe"                   "simple code setup tool"                       "Shell"            "#89e051" #t)
    (make-repo "geonote"                "topics I do care about"                       "HTML"             "#e34c26" #t)
    (make-repo "matteogiorgi.github.io" "personal page witten in Guile"                "Scheme"           "#1e4aec" "readme")))


;;; --------------------------------------------------------------------
;;; Page content
;;; --------------------------------------------------------------------

(define (intro)
  `((h1 "Geoteo")
    (p (@ (class "colophon"))
       "Built with " (a (@ (href "https://www.gnu.org/software/guile/")) "Guile")
       " and " (a (@ (href "https://dthompson.us/projects/haunt.html")) "Haunt") ".")
    (img (@ (class "hero-gif") (src "/static/me.gif") (alt "Matteo Giorgi")
            (width "1000") (height "300")))
    (p "I'm Matthew, a computational tinkerer with a strong foundation in "
       "mathematics, computer science, and finance. I started my studies with "
       (em "Mechanical Engineering") " before earning a BSc in "
       (em "Computer Science") " from the Department of Computer Science, "
       (a (@ (href "https://di.unipi.it/en/")) "University of Pisa")
       ". I'm currently enrolled full-time at the "
       (a (@ (href "https://stat.unibo.it/en/")) "University of Bologna")
       ", Department of Statistical Sciences, pursuing an MSc in " (em "Statistical, Financial and Actuarial Sciences") ".")
    (p "My academic interests lie at the intersection of numerical methods and "
       "mathematical programming, with a particular focus on stochastic optimization "
       "and portfolio management. Additionally, I maintain a keen interest in "
       "cryptanalysis and since the beginning of my studies I have been passionate "
       "about programming languages and compiler construction. Have a look at "
       (code (a (@ (href "https://geoteo.net/geonote/")) "geonote")) ": I keep notes on "
       "some of these topics.")
    (p "I'm also a passionate " (em "Linux") " enthusiast and a long-time "
       (em "Vim") " user. Over the years, I have refined a minimal yet powerful setup "
       "that reflects my preference for efficiency, simplicity and full control of the "
       "development environment; eventually this inspired "
       (code (a (@ (href "https://geoteo.net/ulpe/")) "ulpe"))
       " as my personal project for a streamlined " (em "UNIX") " workspace.")))

(define (contact)
  `(h4 (code (a (@ (href "https://github.com/matteogiorgi")) "GITHUB")) " · "
       (code (a (@ (href "mailto:matteo.giorgi@protonmail.com")) "MAIL")) " · "
       (code (a (@ (href "https://meet.google.com/msc-hnrq-efd")) "MEET"))))

(define (home)
  `(,@(intro)
     (ul (@ (class "repos")) ,@(map repo->sxml pinned-repos))
     ,(contact)
     (p (@ (class "license"))
        (a (@ (href "https://creativecommons.org/licenses/by-sa/4.0")) "CC BY-SA 4.0"))))


;;; --------------------------------------------------------------------
;;; Markdown: just enough of it to render this repo's README.md
;;; --------------------------------------------------------------------

;; Not CommonMark, only the subset the README actually uses, so the build
;; needs nothing beyond Guile and Haunt: `#` headings, paragraphs, `- `
;; lists, ``` fenced code, and inline `code`, *emphasis* and [links](url).
;; Anything else comes through as plain text: extend this if the README
;; starts using more.

;; Inline markup of one line (or paragraph) of text, as a list of SXML
;; nodes. An unclosed delimiter is just kept as text.
(define (md-inline s)
  (let ((n (string-length s)))
    (let loop ((i 0) (start 0) (acc '()))
      (define (emit i* node)
        (loop i* i* (cons node (if (< start i) (cons (substring s start i) acc) acc))))
      (if (>= i n)
          (reverse (if (< start n) (cons (substring s start n) acc) acc))
          (case (string-ref s i)
            ((#\`)
             (let ((j (string-index s #\` (+ i 1))))
               (if j
                   (emit (+ j 1) `(code ,(substring s (+ i 1) j)))
                   (loop (+ i 1) start acc))))
            ((#\*)
             (let ((j (string-index s #\* (+ i 1))))
               (if j
                   (emit (+ j 1) `(em ,@(md-inline (substring s (+ i 1) j))))
                   (loop (+ i 1) start acc))))
            ((#\[)
             (let* ((j (string-index s #\] (+ i 1)))
                    (k (and j (< (+ j 1) n) (char=? (string-ref s (+ j 1)) #\()
                            (string-index s #\) (+ j 2)))))
               (if k
                   (emit (+ k 1) `(a (@ (href ,(substring s (+ j 2) k)))
                                     ,@(md-inline (substring s (+ i 1) j))))
                   (loop (+ i 1) start acc))))
            (else (loop (+ i 1) start acc)))))))

;; Heading id, as Jekyll makes them, so #fragment links match the other
;; Geopages: lowercase, punctuation dropped, spaces to dashes.
(define (md-slug text)
  (list->string
   (filter-map (lambda (c)
                 (cond ((char-alphabetic? c) (char-downcase c))
                       ((char-numeric? c) c)
                       ((memv c '(#\space #\-)) #\-)
                       (else #f)))
               (string->list (string-trim-both text)))))

(define (md-blank? line) (string-null? (string-trim-both line)))
(define (md-fence? line) (string-prefix? "```" line))
(define (md-item? line) (string-prefix? "- " line))
(define (md-heading? line) (string-prefix? "#" line))

;; A fenced code block, marked up as kramdown does (a language-* class
;; around the <pre>), so static/code-blocks.js gives it the same frame,
;; language label and copy button as on the other Geopages.
(define (md-code lang text)
  (if (string-null? lang)
      `(pre (code ,text))
      `(div (@ (class ,(string-append "language-" lang)))
            (pre (code ,text)))))

;; The whole document, as a list of block-level SXML nodes.
(define (markdown->sxml str)
  (let loop ((lines (string-split str #\newline)) (acc '()))
    (cond
     ((null? lines) (reverse acc))
     ((md-blank? (car lines)) (loop (cdr lines) acc))
     ((md-fence? (car lines))
      (let collect ((rest (cdr lines)) (body '()))
        (if (or (null? rest) (md-fence? (car rest)))
            (loop (if (null? rest) rest (cdr rest))
                  (cons (md-code (string-trim-both (substring (car lines) 3))
                                 (string-concatenate
                                  (map (lambda (l) (string-append l "\n")) (reverse body))))
                        acc))
            (collect (cdr rest) (cons (car rest) body)))))
     ((md-heading? (car lines))
      (let* ((line (car lines))
             (level (or (string-skip line #\#) (string-length line)))
             (text (string-trim-both (substring line level)))
             (tag (string->symbol (string-append "h" (number->string (min level 6))))))
        (loop (cdr lines) (cons `(,tag (@ (id ,(md-slug text))) ,@(md-inline text)) acc))))
     ((md-item? (car lines))
      (let collect ((rest lines) (items '()))
        (if (and (pair? rest) (md-item? (car rest)))
            (collect (cdr rest) (cons `(li ,@(md-inline (substring (car rest) 2))) items))
            (loop rest (cons `(ul ,@(reverse items)) acc)))))
     (else
      ;; A paragraph runs until a blank line or the start of another block;
      ;; its lines are joined with a space, as they would render anyway.
      (let collect ((rest lines) (para '()))
        (if (and (pair? rest)
                 (not (md-blank? (car rest)))
                 (or (null? para)
                     (not (or (md-fence? (car rest)) (md-item? (car rest))
                              (md-heading? (car rest))))))
            (collect (cdr rest) (cons (string-trim-both (car rest)) para))
            (loop rest (cons `(p ,@(md-inline (string-join (reverse para) " "))) acc))))))))


;;; --------------------------------------------------------------------
;;; Layout (the HTML shell, as SXML)
;;; --------------------------------------------------------------------

;; Applied in <head>, before first paint, so a stored preference sticks
;; without a flash of the wrong theme. Light is the default (set in CSS);
;; nothing is applied here until the visitor explicitly picks a theme.
;; Also swaps the favicon to match, since that's a per-file <link>, not
;; something CSS can theme. Exposed on window so the toggle script below
;; can reuse it instead of duplicating the favicon logic. Re-applied on
;; `pageshow` too: a bfcache-restored page (browser back/forward) skips
;; this script on the way back, so it can show a theme that's stale
;; relative to what was picked on another geoteo.net page. The favicon
;; URLs carry a `?theme=` query string because browsers cache the tab
;; icon per page URL and often won't re-fetch it on reload just because
;; the <link>'s href changed — each theme needs a genuinely distinct
;; URL to force a fresh icon.
(define theme-init-script
  "(function () {
  window.applyTheme = function () {
    var t = localStorage.getItem('theme');
    if (t) document.documentElement.setAttribute('data-theme', t);
    var src = document.documentElement.getAttribute('data-theme') === 'dark'
      ? '/static/favicon-dark.svg?theme=dark' : '/static/favicon.svg?theme=light';
    var old = document.getElementById('favicon');
    if (old) old.remove();
    var icon = document.createElement('link');
    icon.id = 'favicon';
    icon.rel = 'icon';
    icon.type = 'image/svg+xml';
    icon.href = src;
    document.head.appendChild(icon);
  };
  applyTheme();
  window.addEventListener('pageshow', function (e) {
    if (e.persisted) applyTheme();
  });
})();")

;; Wires up the toggle button: flips data-theme, remembers the choice,
;; then reruns applyTheme so the favicon follows. Which of the two SVG
;; icons is visible is handled by CSS, not JS. A bare T does the same,
;; as long as it isn't meant as text or part of a browser/OS shortcut;
;; held down, it doesn't flicker. Same as in _layouts/default.html.
(define theme-toggle-script
  "(function () {
  var btn = document.getElementById('theme-toggle');
  function toggle() {
    var next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
    window.applyTheme();
  }
  btn.addEventListener('click', toggle);
  document.addEventListener('keydown', function (e) {
    if (e.key.toLowerCase() !== 't' || e.ctrlKey || e.metaKey || e.altKey || e.repeat) return;
    var t = e.target;
    if (t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName)) return;
    toggle();
  });
  // Pointer or Tab, whichever came last: the toolbar tooltips show on
  // focus only after Tab (see .btn-tip in style.css).
  var root = document.documentElement;
  document.addEventListener('pointerdown', function () { root.setAttribute('data-input', 'pointer'); }, true);
  document.addEventListener('keydown', function (e) { if (e.key === 'Tab') root.removeAttribute('data-input'); }, true);
})();")

;; Moon/sun icons for the theme toggle, drawn as inline SVG instead of
;; Unicode glyphs (☾/☀) so they look the same in every browser instead
;; of falling back to whatever emoji font happens to be installed.
;; CSS shows only the one matching the current theme.
(define (moon-icon)
  `(svg (@ (class "icon-moon") (viewBox "0 0 24 24") (width "16") (height "16")
           (aria-hidden "true"))
        (mask (@ (id "moon-mask"))
              (rect (@ (width "24") (height "24") (fill "white")))
              (circle (@ (cx "15") (cy "9") (r "7") (fill "black"))))
        (circle (@ (cx "12") (cy "12") (r "9") (fill "currentColor") (mask "url(#moon-mask)")))))

(define (sun-icon)
  `(svg (@ (class "icon-sun") (viewBox "0 0 24 24") (width "16") (height "16")
           (fill "none") (stroke "currentColor") (stroke-width "2")
           (stroke-linecap "round") (aria-hidden "true"))
        (circle (@ (cx "12") (cy "12") (r "5") (fill "currentColor") (stroke "none")))
        (line (@ (x1 "12") (y1 "2") (x2 "12") (y2 "4")))
        (line (@ (x1 "12") (y1 "20") (x2 "12") (y2 "22")))
        (line (@ (x1 "4") (y1 "12") (x2 "2") (y2 "12")))
        (line (@ (x1 "22") (y1 "12") (x2 "20") (y2 "12")))
        (line (@ (x1 "5.6") (y1 "5.6") (x2 "4.2") (y2 "4.2")))
        (line (@ (x1 "19.8") (y1 "19.8") (x2 "18.4") (y2 "18.4")))
        (line (@ (x1 "5.6") (y1 "18.4") (x2 "4.2") (y2 "19.8")))
        (line (@ (x1 "19.8") (y1 "4.2") (x2 "18.4") (y2 "5.6")))))

;; Index button and popup listing every Geopage, in the order of the cards,
;; with the same markup (and so the same look) as the index popup of the
;; repo pages in _layouts/default.html. Entries can't be expanded there:
;; the language dot of the card takes the triangle's place, and the name
;; and description follow, as on the card. The button
;; starts hidden and static/nav.js reveals it, so it never shows without
;; the script that makes it work.
(define (nav-icon)
  `(svg (@ (viewBox "0 0 16 16") (width "16") (height "16") (aria-hidden "true"))
        (circle (@ (cx "2") (cy "3") (r "1.25") (fill "currentColor")))
        (circle (@ (cx "2") (cy "8") (r "1.25") (fill "currentColor")))
        (circle (@ (cx "2") (cy "13") (r "1.25") (fill "currentColor")))
        (path (@ (d "M5.5 3h9M5.5 8h9M5.5 13h9") (stroke "currentColor")
                 (stroke-width "1.5") (stroke-linecap "round")))))

(define (geopages-nav)
  `((button (@ (id "nav-toggle") (type "button") (class "nav-toggle")
               (aria-label "Geopages") (aria-keyshortcuts "Control+K Meta+K")
               (aria-haspopup "dialog") (hidden "hidden"))
            ,(nav-icon)
            (span (@ (class "btn-tip") (aria-hidden "true"))
                  "Geopages" (kbd "Ctrl K")))
    (dialog (@ (id "nav-dialog") (class "nav-dialog") (aria-labelledby "nav-dialog-title"))
            (div (@ (class "nav-dialog-inner"))
                 (div (@ (class "nav-dialog-head"))
                      (span (@ (id "nav-dialog-title") (class "nav-dialog-title"))
                            "Geopages")
                      (button (@ (type "button") (class "nav-close") (aria-label "Close"))
                              "×"))
                 (nav (@ (id "nav-tree") (class "nav-tree") (tabindex "-1"))
                      (ul (@ (class "nav-repos"))
                          ,@(map (lambda (r)
                                   `(li (@ (class "nav-page"))
                                        (span (@ (class "lang-dot")
                                                 (style ,(string-append "background:" (repo-color r)))))
                                        (a (@ (href ,(repo-pages-url r)))
                                           (code ,(repo-name r)) " "
                                           (span (@ (class "nav-desc")) ,(repo-description r)))))
                                 (filter repo-pages? pinned-repos))))))))

;; With #:repo, the body is a repo's README and gets the same frame as the
;; Geopages built by _layouts/default.html: a .markdown-body wrapper (the
;; styles scoped to it in style.css), the "powered by Geoteo" footer, and
;; static/code-blocks.js for the code blocks.
(define* (layout site title body #:key (nav? #f) (repo #f))
  `((doctype "html")
    (html (@ (lang "en"))
          (head
            (meta (@ (charset "utf-8")))
            (script ,theme-init-script)
            (meta (@ (name "viewport")
                     (content "width=device-width, initial-scale=1.0, user-scalable=yes")))
            (meta (@ (name "color-scheme") (content "light dark")))
            (title ,(if (string-null? title)
                      (site-title site)
                      (string-append title " — " (site-title site))))
            (link (@ (rel "stylesheet") (href "/static/style.css"))))
          (body
            (button (@ (id "theme-toggle") (type "button")
                       (class "theme-toggle") (aria-label "Toggle dark mode")
                       (aria-keyshortcuts "T"))
                    ,(moon-icon) ,(sun-icon)
                    (span (@ (class "btn-tip") (aria-hidden "true"))
                          "Toggle theme" (kbd "T")))
            ,@(if nav? (geopages-nav) '())
            ,(if repo
               `(div (@ (class "markdown-body"))
                     (main ,@body)
                     (p (@ (class "gh-footer"))
                        (a (@ (href ,(string-append "https://github.com/matteogiorgi/" repo)))
                           (code ,repo))
                        " powered by " (a (@ (href "https://geoteo.net")) "Geoteo")))
               `(main ,@body))
            ,@(if repo `((script (@ (src "/static/code-blocks.js")))) '())
            ,@(if nav? `((script (@ (src "/static/nav.js")))) '())
            (script (@ (src "/static/to-top.js")))
            (script ,theme-toggle-script)))))


;;; --------------------------------------------------------------------
;;; Builders
;;; --------------------------------------------------------------------

;; The single home page, the only one with the Geopages popup.
(define (home-page)
  (lambda (site posts)
    (list (make-page "index.html" (layout site "" (home) #:nav? #t) sxml->html))))

;; This repo's own Geopage, at /readme/ (see repo-pages-url): README.md
;; rendered with the subset of Markdown above.
(define (readme-page)
  (lambda (site posts)
    (let ((name "matteogiorgi.github.io"))
      (list (make-page "readme/index.html"
                       (layout site name
                               (markdown->sxml (call-with-input-file "README.md" get-string-all))
                               #:repo name)
                       sxml->html)))))

;; Emit an empty .nojekyll so GitHub Pages serves the output verbatim
;; instead of running it through Jekyll. Regenerated on every build.
(define (nojekyll)
  (lambda (site posts)
    (list (make-page ".nojekyll" ""
                     (lambda (contents port) (display contents port))))))

;; Emit the CNAME file at the build root so GitHub Pages keeps serving
;; the custom domain. Must live at the root, not under static/, so it
;; can't just be dropped in static/ like style.css and favicon.svg.
(define (cname)
  (lambda (site posts)
    (list (make-page "CNAME" (site-domain site)
                     (lambda (contents port) (display contents port))))))


;;; --------------------------------------------------------------------
;;; Site
;;; --------------------------------------------------------------------

(site #:title "(cons geo teo)"
      #:domain "geoteo.net"
      #:build-directory "docs"        ; point GitHub Pages at /docs
      #:default-metadata '((author . "Matteo Giorgi"))
      #:builders (list (home-page)
                       (readme-page)
                       (nojekyll)
                       (cname)
                       (static-directory "static")))
