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
  (make-repo name description language color)
  repo?
  (name        repo-name)         ; string, also the github.com/matteogiorgi/<name> slug
  (description repo-description)  ; string
  (language    repo-language)     ; string, GitHub's detected primary language
  (color       repo-color))       ; string, hex color for the language dot

;; Render a single pinned repo as a card, GitHub-style: name + "Public"
;; badge, description, language dot and name.
(define (repo->sxml r)
  (let ((url (string-append "https://github.com/matteogiorgi/" (repo-name r))))
    `(li (@ (class "repo-card") (id ,(repo-name r)))
         (div (@ (class "repo-head"))
              (code (a (@ (href ,url)) ,(repo-name r)))
              (span (@ (class "badge")) "Public"))
         (p (@ (class "repo-desc")) ,(repo-description r))
         (div (@ (class "repo-lang"))
              (span (@ (class "lang-dot")
                       (style ,(string-append "background:" (repo-color r)))))
              ,(repo-language r)))))

(define pinned-repos
  (list
    (make-repo "matescm"                "tiny implementation of scheme"                "Scheme"           "#1e4aec")
    (make-repo "octet"                  "brainfuck interpreter"                        "Scheme"           "#1e4aec")
    (make-repo "minilispr"              "minimal lisp-to-R compiler"                   "R"                "#198ce7")
    (make-repo "octfmt"                 "GNU-Octave formatter"                         "Go"               "#00add8")
    (make-repo "heapx"                  "experimental C library for heaps"             "C"                "#555555")
    (make-repo "lapq"                   "learning-augmented priority queues"           "C"                "#555555")
    (make-repo "ulpe"                   "UNIX-like work environment"                   "Shell"            "#89e051")
    (make-repo "awkltb"                 "AWK life-table toolkit"                       "Awk"              "#c30e9b")
    (make-repo "nn-option-pricing"      "feed-forward nn to approximate Black-Scholes" "Python"           "#3572a5")
    (make-repo "toody"                  "project for my BSc thesis"                    "Python"           "#3572a5")
    (make-repo "wordle"                 "Wordle implementation from NYT"               "Java"             "#b07219")
    (make-repo "dmenu"                  "patched fork of dmenu"                        "C"                "#555555")
    (make-repo "st"                     "patched fork of st"                           "C"                "#555555")
    (make-repo "slock"                  "patched fork of slock"                        "C"                "#555555")
    (make-repo "nine"                   "Plan9 work environment"                       "Shell"            "#89e051")
    (make-repo "cobe"                   "simple GUI work environment"                  "Shell"            "#89e051")
    (make-repo "vim-notewiki"           "vim plugin for note-taking"                   "Vim Script"       "#199f4b")
    (make-repo "vim-startscreen"        "vim plugin for splash-screen"                 "Vim Script"       "#199f4b")
    (make-repo "wiener"                 "Wiener's attack on RSA"                       "Wolfram Language" "#dd1100")
    (make-repo "asteroids"              "modern implementation of Asteroids"           "JavaScript"       "#f1e05a")
    (make-repo "funint"                 "functional interpreter"                       "OCaml"            "#ef7a08")
    (make-repo "graph"                  "generic objects graph library"                "Java"             "#b07219")
    (make-repo "membox"                 "object repository concurrent server"          "C"                "#555555")
    (make-repo "sparse"                 "sparce matrices functions library"            "C"                "#555555")
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
       (em "Computer Science") " from the "
       (a (@ (href "https://di.unipi.it/en/")) "University of Pisa")
       ", I'm currently enrolled at the "
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

(define (layout site title body)
  `((doctype "html")
    (html (@ (lang "en"))
          (head
            (meta (@ (charset "utf-8")))
            (meta (@ (name "viewport")
                     (content "width=device-width, initial-scale=1.0, user-scalable=yes")))
            (meta (@ (name "color-scheme") (content "light")))
            (title ,(if (string-null? title)
                      (site-title site)
                      (string-append title " — " (site-title site))))
            (link (@ (rel "icon") (type "image/svg+xml") (href "/static/favicon.svg")))
            (link (@ (rel "stylesheet") (href "/static/style.css"))))
          (body
            (main ,@body)))))


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
