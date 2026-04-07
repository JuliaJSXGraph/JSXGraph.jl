# HTML Generation

JSXGraph.jl generates self-contained HTML output that renders interactive
JSXGraph boards in any modern browser. The HTML generation engine supports
both inline asset embedding and CDN-based asset loading.

## Creating a Board

Use the keyword constructor to create a board with common options:

```julia
using JSXGraph

# Basic board with default settings
board = Board("myboard")

# Board with custom axis ranges
board = Board("myboard", xlim=(-10, 10), ylim=(-5, 5))

# Board with grid and custom dimensions
board = Board("myboard", grid=true, width=600, height=400)
```

If you pass an empty string as the `id`, a unique identifier is auto-generated:

```julia
board = Board("")  # id is auto-generated
```

## Generating HTML

### Full Page

Generate a complete HTML document that can be opened directly in a browser:

```julia
html = html_string(board)
# or equivalently:
html = html_page(board)
```

### Fragment

Generate an embeddable HTML fragment (div + script, no DOCTYPE/head/body):

```julia
html = html_string(board; full_page=false)
# or equivalently:
html = html_fragment(board)
```

### CDN Mode

Generate smaller output by referencing JSXGraph from a CDN instead of inlining
the full library:

```julia
html = html_string(board; asset_mode=:cdn)
```

CDN mode produces output that is at least 80% smaller than inline mode, but
requires an internet connection when viewing.

## Saving to File

Save a board as a self-contained HTML file:

```julia
board = Board("myboard", xlim=(-5, 5), ylim=(-5, 5))
push!(board, point(1, 2; color="red"))

# Save with inlined assets (default — works offline)
save("plot.html", board)

# Save with CDN references (smaller file, needs internet)
save("plot_cdn.html", board; asset_mode=:cdn)
```

## Version Information

The bundled JSXGraph library version is available as:

```julia
JSXGRAPH_VERSION  # "1.12.2"
```

## API Reference

```@docs
html_string
html_page
html_fragment
save
```
