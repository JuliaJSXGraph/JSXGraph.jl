# JSXGraph

| CI | Coverage | Documentation |
| :-: | :------: | :-----------: |
| [![CI](https://github.com/JuliaJSXGraph/JSXGraph.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaJSXGraph/JSXGraph.jl/actions/workflows/CI.yml) | [![codecov](https://codecov.io/gh/JuliaJSXGraph/JSXGraph.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaJSXGraph/JSXGraph.jl) | WIP

[jsxgraph](https://github.com/jsxgraph/jsxgraph) is a nice project to have interactive plots in the browser, it's a bit like Plotly except more geared towards maths and interactivity.

This package aims to help generate JSXGraph code from Julia code that can then be plugged in a statically served website (for instance one you would generate via [Franklin.jl](https://github.com/tlienart/Franklin.jl)).

## Getting started

Check out [this page](https://tlienart.github.io/JSXGraphWeb/) for a gallery of examples and explanations.
This is still very much WIP so your help and suggestions are very welcome if you think this project might be useful to you in some form.

## Todo

The wrapper is incomplete to say the least, there are two easy ways to go forward (both of which should be done), it just requires the time to do it and test it:

1. wrap more of the jsxgraph objects like [`chart`](https://jsxgraph.org/docs/symbols/Chart.html), [`glider`](https://jsxgraph.org/docs/symbols/Glider.html), [`group`](https://jsxgraph.org/docs/symbols/Group.html), [`grid`](https://jsxgraph.org/docs/symbols/Grid.html), [`integral`](https://jsxgraph.org/docs/symbols/Integral.html), etc...
2. add aliases for the common options like `strokecolor`, `strokewidth` etc. so that people who are used to `Plots.jl` options can just use those, for instance we should allow `col`, `color` or `linecolor` as alias for `strokecolor`.

Then of course, generating many examples is always good, they have [many examples](https://jsxgraph.org/wp/about/index.html) which could be ported over in some form or other.

## Dependencies

The `src/libs` folder contains a copy of `jsxgraph.css` and `jsxgraphcore.js`. Both are provided "as is", but you could also download your own versions from [the original repo](https://github.com/jsxgraph/jsxgraph/tree/master/update_cdnjs).

## License

* the original JSXGraph package is released under a dual LGPL/MIT license.
* this package (which just wraps around JSXGraph) is released under the MIT license.

## FAQ

### Shouldn't you just write Javascript?

Probably.
