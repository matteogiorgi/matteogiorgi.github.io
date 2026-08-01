;;; haunt.scm --- geoteo.net
;;;
;;; Build a static, single-page site with Haunt (GNU Guile).
;;;
;;;   haunt build            build into ./docs
;;;   haunt serve --watch    live preview on http://localhost:8080
;;;
;;; The site is a Scheme program: the "Experiences" section is generated
;;; from the `experiences' data list below, so adding/reordering a project
;;; means editing data, not markup.

(use-modules (haunt site)
             (haunt page)
             (haunt html)
             (haunt builder assets)
             (srfi srfi-9))          ; define-record-type


;;; --------------------------------------------------------------------
;;; Data model: one experience = name + optional url + SXML body
;;; --------------------------------------------------------------------

(define-record-type <xp>
  (make-xp name url body)
  xp?
  (name xp-name)          ; string, rendered in monospace
  (url  xp-url)           ; string or #f
  (body xp-body))         ; SXML fragment (list of inline nodes)

;; Render a single experience as an <li>. The id (derived from the name)
;; makes every item linkable, e.g. the #podeen anchor in the intro.
(define (xp->sxml x)
  (let* ((name (xp-name x))
         (url  (xp-url x))
         (tag  (if url `(a (@ (href ,url)) ,name) name)))
    `(li (@ (id ,(string-downcase name)))
         (code ,tag) " " ,@(xp-body x))))

(define experiences
  (list
    (make-xp "IMC-CHALLENGE"
             "https://www.linkedin.com/feed/update/urn:li:activity:7321961774625218560/"
             '("First italian team and ranked 108th worldwide in the 2025 edition of "
               (em "IMC Prosperity Challenge") ", a 15-day international algorithmic "
               "trading competition with more than 12,000 participants. Teaming up with "
               "other three " (em "University of Padua") " graduates from Computational "
               "Finance and Statistics, we implemented robust " (em "Python") " algorithms, "
               "tackled tricky probability brainteasers, and delivered a top national "
               "performance, culminating in a +155K profit during the final round."))
    (make-xp "TOODY"
             "https://github.com/matteogiorgi/toody"
             '("Designed and developed a " (em "Python") " web application from scratch to "
               "analyze software requirements documents and detect variability indicators. "
               "Built as part of my BSc thesis, the project covers both backend and frontend, "
               "using " (em "Flask") " for the web interface and " (em "spaCy")
               " for natural language processing."))
    (make-xp "LAB-ASSISTANT"
             "http://didawiki.di.unipi.it/doku.php/fisica/informatica/201617/start"
             '("Worked, in support of Professor Pelagatti, as lab assistant for the "
               (em "C") " laboratory exam at BSc in Physics at the "
               (em "University of Pisa") ". The main task was to help students during "
               "the exercise sessions and to correct their assignments."))
    (make-xp "PODEEN"
             "https://github.com/matteogiorgi/podeen"
             '("Public repository containing a collection of configuration files and "
               "installation scripts for a complete and efficient minimal " (em "UNIX")
               " work environment based on any " (em "Debian") " distribution."))
    (make-xp "ASTEROIDS"
             "https://github.com/matteogiorgi/asteroids"
             '((em "JavaScript") " implementation of the popular game " (em "Asteroids")
                                 ". The game is written using the " (em "p5.js") " library and is "
                                 "particularly useful to understand the basics of event programming."))
    (make-xp "WIENER-REPORT"
             "https://github.com/matteogiorgi/wiener"
             '("Independent studies, under the supervision of Professor Romani from the "
               (em "University of Pisa") ", regarding the attacks that exploit the "
               (em "RSA") " cryptosystem vulnerabilities with a specific focus on the "
               (em "Wiener Attack") " and its use of " (em "Continued Fractions")
               " for the factorization of the " (em "RSA") " module."))
    (make-xp "FUNINT"
             "https://github.com/matteogiorgi/funint"
             '("Designed and implemented an " (em "Ocaml") " interpreter for a toy "
               "language with static scoping and dynamic type checking that is able to "
               "handle tuple of expressions and combine functions."))
    (make-xp "WORDLE"
             "https://github.com/matteogiorgi/wordle"
             '("Developed a " (em "Java") " implementation of the popular game Wordle "
               "from the New York Times. The project focused on handling efficient string "
               "comparison algorithms for word matching in a classic client-server structure."))
    (make-xp "GRAPH"
             "https://github.com/matteogiorgi/graph"
             '("Implemented a " (em "Java") " undirected graph library for homogeneous "
               "generic objects. The project was particularly useful for strengthening "
               "skills in object-oriented design and modularity, emphasizing code "
               "reusability and clean separation of concerns."))
    (make-xp "MEMBOX"
             "https://github.com/matteogiorgi/membox"
             '("Developed a concurrent " (em "C") " server for a virtual repository "
               "system, capable of handling non-null sequences of bytes with "
               "synchronization primitives to ensure safe access in multi-threaded "
               "environments. The focus was on implementing robust memory management "
               "and concurrent data structures under " (em "POSIX") " threads."))
    (make-xp "SPARSE"
             "https://github.com/matteogiorgi/sparse"
             '("Implemented a simple " (em "C") " library that allows to handle sparce "
               "matrices efficiently. The project was particularly valuable for practicing "
               "pointer management in " (em "C") ", improving both memory efficiency and "
               "low-level programming skills."))
    (make-xp "COMPUTABILITY"
             "https://github.com/matteogiorgi/computability"
             '("Attempted to write a comprehensive set of notes and examples on the theory "
               "of computability, covering topics such as Turing machines, recursive "
               "functions, and undecidability. While the project was not completed, it "
               "provided valuable exposure to theoretical computer science and its "
               "connections with formal language theory."))
    (make-xp "HACKATHON"
             "http://contaminationlab.unipi.it/conthackt-foodmobilitydigital"
             '("First place in the 2021 edition of " (em "ContHackt") ", organized by the "
               (em "University of Pisa") " and " (em "Contamination Lab Pisa") ". As winner, "
               "our team had access to the 2021/2022 " (em "EUAcceL") " project organized by "
               "the " (em "European Institute of Innovation and Technology") " and won the "
               "final stage with a blockchain prototype for the tracking of food products."))
    (make-xp "CNR-PROJECT" #f
             '("Worked, together with a colleague of mine, as a " (em "Python")
               " programmer inside the " (em "CNR") " offices in Pisa, helping in the "
               "realization of a scale model for blind people. The project was under the "
               "supervision of Doctor Furfari from " (em "CNR") " and Professor Pelagatti "
               "from the " (em "University of Pisa") "."))
    (make-xp "TUTORING" #f
             '("Provided support to university students in " (em "Mathematics") ", "
               (em "Statistics") ", " (em "Computer Science") ", and " (em "Physics")
               ", developing strong communication and adaptability skills while "
               "reinforcing foundational knowledge."))))


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
    (make-repo "ulpe"                   "work environment"                             "Shell"            "#89e051")
    (make-repo "nn-option-pricing"      "feed-forward nn to approximate Black-Scholes" "Python"           "#3572a5")
    (make-repo "lapq"                   "learning augmented priority queues"           "C"                "#555555")
    (make-repo "toody"                  "project for my BSc thesis"                    "Python"           "#3572a5")
    (make-repo "worlde"                 "Wordle implementation from NYT"               "Java"             "#b07219")
    (make-repo "dmenu"                  "patched fork of dmenu"                        "C"                "#555555")
    (make-repo "st"                     "patched fork of st"                           "C"                "#555555")
    (make-repo "slock"                  "patched fork of slock"                        "C"                "#555555")
    (make-repo "wiener"                 "Wiener's attack on RSA"                       "Wolfram Language" "#dd1100")
    (make-repo "vim-notewiki"           "vim plugin for note-taking"                   "Vim Script"       "#199f4b")
    (make-repo "vim-startscreen"        "vim plugin for splash-screen"                 "Vim Script"       "#199f4b")
    (make-repo "asteroids"              "modern implementation of Asteroids"           "JavaScript"       "#f1e05a")
    (make-repo "funint"                 "functional interpreter"                       "OCaml"            "#ef7a08")
    (make-repo "membox"                 "object repository concurrent server"          "C"                "#555555")
    (make-repo "sparse"                 "sparce matrices functions library"            "C"                "#555555")
    (make-repo "graph"                  "generic objects graph library"                "Java"             "#b07219")
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
       (a (@ (href "#ulpe")) (code "ULPE"))
       " as my personal project for a streamlined " (em "UNIX") " workspace.")))

(define (contact)
  `(h4 (code (a (@ (href "https://geoteo.net/cv/src/cv.pdf")) "CV")) " · "
       (code (a (@ (href "https://github.com/matteogiorgi")) "GITHUB")) " · "
       (code (a (@ (href "mailto:matteo.giorgi@protonmail.com")) "MAIL")) " · "
       (code (a (@ (href "https://meet.google.com/msc-hnrq-efd")) "MEET"))))

(define (home)
  `(,@(intro)
     #|
     (h2 "Experiences")
     (ul ,@(map xp->sxml experiences))
     |#
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
