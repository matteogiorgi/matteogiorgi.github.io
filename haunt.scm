;;; haunt.scm --- geoteo.net
;;;
;;; Build a static, single-page site with Haunt (GNU Guile).
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
  (pages?      repo-pages?))      ; boolean, has a GitHub Pages site at geoteo.net/<name>/

;; Most repos don't have a Pages site, so make that argument optional.
(define* (make-repo name description language color #:optional (pages? #f))
  (make-repo* name description language color pages?))

;; Render a single pinned repo as a card, GitHub-style: name + "Public"
;; badge, description, language dot and name. The badge becomes a link to
;; the repo's GitHub Pages site when it has one, plain text otherwise.
(define (repo->sxml r)
  (let ((url (string-append "https://github.com/matteogiorgi/" (repo-name r))))
    `(li (@ (class "repo-card") (id ,(repo-name r)))
         (div (@ (class "repo-head"))
              (code (a (@ (href ,url)) ,(repo-name r)))
              ,(if (repo-pages? r)
                 `(a (@ (class "badge badge-link")
                        (href ,(string-append "https://geoteo.net/" (repo-name r) "/")))
                     "Public")
                 `(span (@ (class "badge")) "Public")))
         (p (@ (class "repo-desc")) ,(repo-description r))
         (div (@ (class "repo-lang"))
              (span (@ (class "lang-dot")
                       (style ,(string-append "background:" (repo-color r)))))
              ,(repo-language r)))))

(define pinned-repos
  (list
    (make-repo "karp"                   "explicit NP-complete reductions"              "Go"               "#00add8" #t)
    (make-repo "octfmt"                 "GNU-Octave formatter"                         "Go"               "#00add8")
    (make-repo "matescm"                "tiny implementation of scheme"                "Scheme"           "#1e4aec")
    (make-repo "octet"                  "brainfuck interpreter"                        "Scheme"           "#1e4aec")
    (make-repo "minilispr"              "minimal lisp-to-R compiler"                   "R"                "#198ce7")
    (make-repo "awkltb"                 "AWK life-table toolkit"                       "Awk"              "#c30e9b")
    (make-repo "heapx"                  "experimental C library for heaps"             "C"                "#555555")
    (make-repo "lapq"                   "learning-augmented priority queues"           "C"                "#555555")
    (make-repo "ulpe"                   "UNIX-like work environment"                   "Shell"            "#89e051" #t)
    (make-repo "nine"                   "plan9port zero-config setup"                  "Shell"            "#89e051" #t)
    (make-repo "nn-option-pricing"      "feed-forward nn to approximate Black-Scholes" "Python"           "#3572a5" #t)
    (make-repo "toody"                  "project for my BSc thesis"                    "Python"           "#3572a5")
    (make-repo "wordle"                 "Wordle implementation from NYT"               "Java"             "#b07219" #t)
    (make-repo "dmenu"                  "patched fork of dmenu"                        "C"                "#555555")
    (make-repo "st"                     "patched fork of st"                           "C"                "#555555")
    (make-repo "slock"                  "patched fork of slock"                        "C"                "#555555")
    (make-repo "vim-notewiki"           "vim plugin for note-taking"                   "Vim Script"       "#199f4b")
    (make-repo "vim-startscreen"        "vim plugin for splash-screen"                 "Vim Script"       "#199f4b")
    (make-repo "wiener"                 "Wiener's attack on RSA"                       "Wolfram Language" "#dd1100")
    (make-repo "asteroids"              "modern implementation of Asteroids"           "JavaScript"       "#f1e05a" #t)
    (make-repo "funint"                 "functional interpreter"                       "OCaml"            "#ef7a08")
    (make-repo "graph"                  "generic objects graph library"                "Java"             "#b07219")
    (make-repo "membox"                 "object repository concurrent server"          "C"                "#555555")
    (make-repo "sparse"                 "sparce matrices functions library"            "C"                "#555555")
    (make-repo "cobe"                   "simple code setup tool"                       "Shell"            "#89e051" #t)
    (make-repo "matteogiorgi.github.io" "personal page witten in Guile"                "Scheme"           "#1e4aec")))


;;; --------------------------------------------------------------------
;;; Page content
;;; --------------------------------------------------------------------

(define (intro)
  `((h1 "Geoteo")
    (p (@ (class "colophon"))
       "Built with " (a (@ (href "https://www.gnu.org/software/guile/")) "Guile")
       " and " (a (@ (href "https://dthompson.us/projects/haunt.html")) "Haunt") ".")
    (p "I'm Matthew, a computational tinkerer with a strong foundation in "
       "mathematics, computer science, and finance. Holding a BSc in "
       (em "Computer Science") " from the Department of Computer Science, "
       (a (@ (href "https://di.unipi.it/en/")) "University of Pisa")
       ", I'm currently enrolled full-time at the "
       (a (@ (href "https://stat.unibo.it/en/")) "University of Bologna")
       ", Department of Statistical Sciences, pursuing an MSc in " (em "Statistical, Financial and Actuarial Sciences") ".")
    (p "My academic interests lie at the intersection of numerical methods and "
       "mathematical programming, with a particular focus on stochastic optimization "
       "and portfolio management. Additionally, I maintain a keen interest in "
       "cryptanalysis and since the beginning of my studies I have been passionate "
       "about programming languages and compiler construction.")
    (p "I'm also a passionate " (em "Linux") " enthusiast and a long-time "
       (em "Vim") " user. Over the years, I have refined a minimal yet powerful setup "
       "that reflects my preference for efficiency, simplicity and full control of the "
       "development environment; eventually this inspired "
       (a (@ (href "https://geoteo.net/ulpe/")) (code "ULPE"))
       " as my personal project for a streamlined " (em "UNIX") " workspace.")))

(define (contact)
  `(h4 (code (a (@ (href "https://geoteo.net/cv/src/cv.pdf")) "CV")) " · "
       (code (a (@ (href "https://github.com/matteogiorgi")) "GITHUB")) " · "
       (code (a (@ (href "mailto:matteo.giorgi@protonmail.com")) "MAIL")) " · "
       (code (a (@ (href "https://meet.google.com/msc-hnrq-efd")) "MEET"))))

(define (home)
  `(,@(intro)
     (ul (@ (class "repos")) ,@(map repo->sxml pinned-repos))
     ,(contact)
     (p (@ (class "license"))
        (a (@ (href "https://creativecommons.org/licenses/by-sa/4.0")) "CC BY-SA 4.0"))))


;;; --------------------------------------------------------------------
;;; Layout (the HTML shell, as SXML)
;;; --------------------------------------------------------------------

;; Applied in <head>, before first paint, so a stored preference sticks
;; without a flash of the wrong theme. Light is the default (set in CSS);
;; nothing is applied here until the visitor explicitly picks a theme.
(define theme-init-script
  "(function () {
  var t = localStorage.getItem('theme');
  if (t) document.documentElement.setAttribute('data-theme', t);
})();")

;; Wires up the toggle button: just flips data-theme and remembers the
;; choice. Which of the two SVG icons is visible is handled by CSS, not
;; JS. The only client-side JavaScript on the site.
(define theme-toggle-script
  "(function () {
  var btn = document.getElementById('theme-toggle');
  btn.addEventListener('click', function () {
    var next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
  });
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

(define (layout site title body)
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
            (link (@ (rel "icon") (type "image/svg+xml") (href "/static/favicon.svg")))
            (link (@ (rel "stylesheet") (href "/static/style.css"))))
          (body
            (button (@ (id "theme-toggle") (type "button")
                       (class "theme-toggle") (aria-label "Toggle dark mode"))
                    ,(moon-icon) ,(sun-icon))
            (main ,@body)
            (script ,theme-toggle-script)))))


;;; --------------------------------------------------------------------
;;; Builders
;;; --------------------------------------------------------------------

;; The single home page.
(define (home-page)
  (lambda (site posts)
    (list (make-page "index.html" (layout site "" (home)) sxml->html))))

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
                       (nojekyll)
                       (cname)
                       (static-directory "static")))
