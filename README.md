# Geoteo

Source for my personal website, [geoteo.net](https://geoteo.net). The site is a single Scheme program (`haunt.scm`) built with [Haunt](https://dthompson.us/projects/haunt.html), the static site generator for [GNU Guile](https://www.gnu.org/software/guile/): content — bio, pinned repos, contact links — lives as Scheme data, and the page is generated from it as SXML, with no client-side JavaScript.




## Layout

- `haunt.scm` — site content, page layout, and build configuration
- `static/` — stylesheet and favicon, copied as-is into the build
- `docs/` — generated output, served directly by GitHub Pages




## Build

Requires [GNU Guile](https://www.gnu.org/software/guile/) and [Haunt](https://dthompson.us/projects/haunt.html) installed.

```sh
haunt build            # build into ./docs
haunt serve --watch    # live preview on http://localhost:8080
```




## License

Content is licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0).
