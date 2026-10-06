# Geoteo: a static site as a Scheme program

Source for my personal website, [geoteo.net](https://geoteo.net), built with *Haunt*, the static site generator for *GNU Guile*. The whole site is a single Scheme program (`haunt.scm`): content lives as data, and the pages are generated from it as SXML, this README included, rendered as the repo's own [Geopage](https://geoteo.net/readme/). Client-side JavaScript is limited to a few small scripts: the light/dark theme toggle (`T`), the Geopages popup (`Ctrl K`), the back-to-top button, and the copy button on code blocks.

The repo also hosts the Jekyll theme of the other Geopages, which pull it in as a `remote_theme`.




## Layout

- [`haunt.scm`](https://github.com/matteogiorgi/matteogiorgi.github.io/blob/main/haunt.scm) — site content, page layout, Markdown rendering of this README, and build configuration
- [`static/`](https://github.com/matteogiorgi/matteogiorgi.github.io/tree/main/static) — stylesheet, favicons, and scripts, copied as-is into the build and shared with the other Geopages
- [`_layouts/`](https://github.com/matteogiorgi/matteogiorgi.github.io/tree/main/_layouts) — Jekyll layout of the other Geopages
- [`.github/`](https://github.com/matteogiorgi/matteogiorgi.github.io/tree/main/.github) — workflow rebuilding the other Geopages whenever their layout changes
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
