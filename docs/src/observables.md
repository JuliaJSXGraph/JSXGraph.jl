# Observables.jl Integration

JSXGraph.jl supports [Observables.jl](https://github.com/JuliaGizmos/Observables.jl) as an optional dependency. When loaded, `Observable` values can be used as element parents or attributes — they are automatically unwrapped to their current value at render time.

## Setup

```julia
using JSXGraph
using Observables
```

## Basic Usage

Use `Observable` values anywhere you would use a plain number, string, or other value:

```julia
x = Observable(1.0)
y = Observable(2.0)
color = Observable("blue")

b = Board("obs_demo"; xlim=(-5, 5), ylim=(-5, 5))
push!(b, point(x, y; strokeColor=color, name="P"))
html_string(b)  # renders with x=1.0, y=2.0, color="blue"
```

Updating the observable before the next render changes the output:

```julia
x[] = 3.0
color[] = "red"
html_string(b)  # now renders with x=3.0, color="red"
```

## Pluto.jl Reactivity

In [Pluto.jl](https://plutojl.org/) notebooks, Observables integrate naturally with Pluto's reactivity model. When an `Observable` value changes, any cell that references it re-executes, regenerating the board with the updated values.

```julia
# Cell 1
using JSXGraph, Observables
x_pos = Observable(0.0)

# Cell 2
begin
    b = Board("pluto_demo"; xlim=(-5, 5), ylim=(-5, 5))
    push!(b, point(x_pos, 0.0; name="P", size=5))
    b
end

# Cell 3 — changing this triggers Cell 2 to re-render
x_pos[] = 3.0
```

## How It Works

The integration uses Julia's package extension mechanism. When `Observables` is loaded alongside `JSXGraph`, the `JSXGraphObservablesExt` extension activates and adds a method to `JSXGraph.resolve_value` that unwraps `Observable{T}` to its current value `T`. This unwrapping happens transparently during HTML/JS generation, so all element constructors and attribute processing work with Observables without any special syntax.
