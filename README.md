# Geoteo

Source for my personal website, [geoteo.net](https://geoteo.net), built with *Haunt*, the static site generator for *GNU Guile*. The whole site is a single Scheme program (`haunt.scm`): content lives as data, and the page is generated from it as SXML. The only client-side JavaScript is a small snippet powering the light/dark theme toggle.




## Layout

- [`haunt.scm`](https://github.com/matteogiorgi/matteogiorgi.github.io/blob/main/haunt.scm) — site content, page layout, and build configuration
- [`static/`](https://github.com/matteogiorgi/matteogiorgi.github.io/tree/main/static) — stylesheet and favicon, copied as-is into the build
- [`docs/`](https://github.com/matteogiorgi/matteogiorgi.github.io/tree/main/docs) — generated output, served directly by GitHub Pages




## Build

Requires [GNU Guile](https://www.gnu.org/software/guile/) and [Haunt](https://dthompson.us/projects/haunt.html) installed.

```sh
haunt build            # build into ./docs
haunt serve --watch    # live preview on http://localhost:8080
```




## License

Content is licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0).
