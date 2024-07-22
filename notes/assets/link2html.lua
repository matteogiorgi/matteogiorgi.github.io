-- #!/usr/bin/env lua

-- This script is used by MakeNote function to convert links inside
-- *.md files into html links inside the newly created *.html files.
-- [--lua-filter=$pandoc/assets/link2html.lua]


function Link(el)
    el.target = string.gsub(el.target, "%.md", ".html")
    return el
end
