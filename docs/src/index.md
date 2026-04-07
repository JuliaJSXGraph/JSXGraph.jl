# JSXGraph.jl

*Interactive mathematical visualization in the browser, powered by [JSXGraph](https://jsxgraph.uni-bayreuth.de/).*

## Overview

JSXGraph.jl is a Julia package for creating interactive mathematical visualizations
that run natively in the browser. It generates self-contained HTML/JavaScript output
using the [JSXGraph](https://jsxgraph.uni-bayreuth.de/) library, enabling dynamic
geometry, function exploration, and interactive constructions without requiring a
running Julia process.

## Features

- Interactive geometric constructions (points, lines, circles, polygons, etc.)
- Function plotting with real-time parameter exploration via sliders
- Native rendering in Jupyter, Pluto, VS Code, and the REPL
- Lightweight with minimal dependencies
- Julia-idiomatic API with Plots.jl-compatible keyword aliases
- Package extensions for Colors.jl, Unitful.jl, Tables.jl, and Observables.jl

## Installation

```julia
using Pkg

Pkg.develop("https://github.com/JuliaJSXGraph/JSXGraph.jl/")

# or

Pkg.add("JSXGraph")  # when registered in Julia General Registry
```

## Quick Start

```julia
using JSXGraph

# Create a board with axis ranges
board = Board("myboard", xlim=(-5, 5), ylim=(-5, 5))

# Generate a self-contained HTML page
html = html_string(board)

# Or use CDN mode for smaller output
html = html_string(board; asset_mode=:cdn)
```

See the [Getting Started](@ref) tutorial for a comprehensive walkthrough.

## API Reference

See the [API Reference](api.md) page for all exported functions and types.
