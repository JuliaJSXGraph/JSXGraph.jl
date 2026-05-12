# Pluto Integration

JSXGraph.jl integrates with [Pluto.jl](https://plutojl.org)'s reactive
`@bind` mechanism, letting you read the live state of a board's
interactive elements (draggable points, sliders) directly into Julia
variables — and have any downstream cell re-execute automatically when
the user drags something in the browser.

## Quickstart

Opt in by passing `bindable=true` to `board(...)`:

```julia
using JSXGraph

@bind state board("demo"; xlim=(-5, 5), ylim=(-5, 5), bindable=true) do b
    push!(b, point(-2.0,  1.0; name="A"))
    push!(b, point( 0.0, -1.0; name="B"))
    push!(b, point( 2.0,  2.0; name="C"))
end
```

In another cell:

```julia
xs, ys = points_xy(state)   # parallel vectors in declaration order
state["A"].x                 # access by element name
```

Drag any point in the rendered board → both cells re-evaluate.

## Bound-state shape

When `bindable=true`, the bound value is a `Dict{String,Any}`:

| Element kind | Key | Value |
| --- | --- | --- |
| `point` (2D, not fixed) | `name` attr, else `"point_$i"` | `(x = …, y = …)` named tuple |
| `point3d` (not fixed) | `name`, else `"point3d_$i"` | `(x = …, y = …, z = …)` |
| `slider` | `name`, else `"slider_$i"` | `Float64` value |

Other element kinds (curves, lines, axes, …) do not contribute to the
bound state.

## Helpers

```julia
points_xy(state)  -> (xs::Vector{Float64}, ys::Vector{Float64})
points_xyz(state) -> (xs::Vector{Float64}, ys::Vector{Float64}, zs::Vector{Float64})
```

Both helpers project the bound state into parallel coordinate vectors in
element-declaration order. `points_xy` skips 3D points and sliders;
`points_xyz` skips 2D points and sliders.

## Duplicate names

A bindable board with two interactive elements sharing the same `name`
raises `ArgumentError` at construction time — the bound-state schema
needs unambiguous keys.

```julia
board("dup"; bindable=true) do b
    push!(b, point(0.0, 0.0; name="X"))
    push!(b, point(1.0, 1.0; name="X"))  # → ArgumentError
end
```

Non-bindable boards keep current behaviour (duplicates allowed).

## How it works

When `bindable=true`, the renderer wraps the board's `<div>` in an outer
`<span>` whose `.value` property holds the current state. A throttled
JavaScript handler (≈30 Hz) updates `.value` and dispatches a standard
`input` event on every interactive change, with an unconditional final
fire on drag-end. Pluto's `@bind` macro listens for that event — no
custom protocol, no extra dependencies on the Julia side.

Outside Pluto (raw HTML page, Documenter, Jupyter), the wrapper is
inert: the board renders normally and the `input` event fires
harmlessly with nothing listening.

If `AbstractPlutoDingetjes` is loaded (which Pluto does automatically),
seed coordinates flow through Pluto's binary `published_to_js` channel
instead of being inlined as JSON literals — useful for boards with very
large seed arrays. The package extension `JSXGraphAbstractPlutoDingetjesExt`
makes this transparent; the JSON fallback is used everywhere else.

## Runnable example

The following Pluto notebook demonstrates a complete spline-editor
workflow: drag points in a JSXGraph board, and a Makie plot of the
fitted spline recomputes reactively.

[Download the notebook](assets/pluto_bind_demo.jl) — open it in Pluto
locally to interact with it.

<!-- PLUTO_NOTEBOOK_START -->

> When the documentation is built with `BUILD_PLUTO_NOTEBOOKS=true`, the
> rendered notebook output is inlined here by `PlutoStaticHTML.jl`.

<!-- PLUTO_NOTEBOOK_END -->

## API reference

```@docs
points_xy
points_xyz
```
