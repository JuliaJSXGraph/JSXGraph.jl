# JSXGraph.jl

[![CI](https://github.com/JuliaJSXGraph/JSXGraph.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaJSXGraph/JSXGraph.jl/actions/workflows/CI.yml)
[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaJSXGraph.github.io/JSXGraph.jl/stable/)
[![Dev Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaJSXGraph.github.io/JSXGraph.jl/dev/)
[![codecov](https://codecov.io/gh/JuliaJSXGraph/JSXGraph.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaJSXGraph/JSXGraph.jl)

A Julia package for creating interactive geometry, function plotting, and data visualization using [JSXGraph](https://jsxgraph.org/).

## Installation

```julia
using Pkg

Pkg.add("JSXGraph")
```

## Quick Start

```julia
using JSXGraph

# Create a board with a point and a line
b = board("box", xlim=(-5, 5), ylim=(-5, 5))
A = point(1, 2; name="A")
B = point(-3, -1; name="B")
l = line(A, B)
push!(b, A, B, l)

# Display as HTML
html(b)
```

## Documentation

- [**Stable**](https://JuliaJSXGraph.github.io/JSXGraph.jl/stable/) — documentation for the latest tagged release
- [**Dev**](https://JuliaJSXGraph.github.io/JSXGraph.jl/dev/) — documentation for the current `main` branch

## License

MIT — see [LICENSE](LICENSE) for details.
