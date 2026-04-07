# Display Protocol

JSXGraph.jl integrates with Julia's display system so that `Board` objects
render automatically in notebooks and show a compact summary in the REPL.

## Automatic Notebook Display

In Jupyter/IJulia, VS Code Julia, or Pluto.jl notebooks, simply evaluate a
`Board` expression — no extra function calls needed:

```julia
using JSXGraph

board = Board("myboard", xlim=(-5, 5), ylim=(-5, 5))
board  # renders interactively in the notebook cell
```

Each display call generates a unique div ID (`jxg_` + 12 random characters)
to avoid DOM conflicts when the same board is shown in multiple cells.

The notebook output uses CDN mode for compact output — no 960 KB JavaScript
is embedded per cell.

## REPL Text Summary

In the plain REPL, evaluating a board prints a compact one-line summary:

```
Board("myboard", 0 elements, x=[-5,5], y=[-5,5], 500x500px)
```

## Opening in Browser

To open a board in your default web browser from the REPL, load
`DefaultApplication.jl`:

```julia
using JSXGraph
using DefaultApplication

board = Board("myboard", xlim=(-5, 5), ylim=(-5, 5))
open_in_browser(board)
```

The `open_in_browser` function creates a temporary HTML file with the full
inline JSXGraph library and opens it in the default browser.

See [`open_in_browser`](@ref) in the API Reference for details.

## Documenter.jl Integration

Documenter.jl `@example` blocks automatically call the `text/html` MIME show
method, so boards render as interactive visualizations in generated
documentation:

````markdown
```@example
using JSXGraph
Board("example", xlim=(-5, 5), ylim=(-5, 5))
```
````

The output is a compact CDN-based HTML fragment (under 2 KB) that works
within Documenter's HTML output.

## Pluto.jl Compatibility

Boards work in Pluto.jl with no special handling. The HTML output:

- Uses CDN `<link>` tags instead of `<style>` tags (Pluto's DOMPurify strips
  inline styles in style elements)
- Applies styles via the `style=` attribute on the div
- Generates a unique ID per display call (compatible with Pluto's reactive
  re-rendering model)
