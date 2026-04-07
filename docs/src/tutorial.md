# Getting Started

This tutorial walks you through the basics of JSXGraph.jl, from installation
to interactive visualizations. By the end, you will know how to create boards,
add geometric elements, plot functions, style your figures, and export them.

## Installation

```julia
using Pkg
Pkg.add("JSXGraph")
```

## Your First Board

A [`Board`](@ref) is the canvas on which all elements are drawn. Create one by
specifying an identifier and axis limits:

```julia
using JSXGraph

b = Board("first", xlim=(-5, 5), ylim=(-5, 5))
```

In **Jupyter**, **Pluto**, or the **VS Code** Julia plot pane, the board renders
automatically. In the **REPL**, calling `display(b)` opens it in your default
browser (requires [DefaultApplication.jl](https://github.com/tpapp/DefaultApplication.jl)).

## Adding Elements

### Points and Lines

Create geometric elements and add them to a board with [`push!`](@ref) or the
`+` operator:

```julia
using JSXGraph

b = Board("points", xlim=(-5, 5), ylim=(-5, 5))

p1 = point(-2, 1; name="A", color="red", size=4)
p2 = point(3, 2; name="B", color="blue", size=4)
l  = line(p1, p2; strokeWidth=2)

push!(b, p1, p2, l)
```

The `+` operator returns a new board without mutating the original:

```julia
b = Board("nonmut", xlim=(-5, 5), ylim=(-5, 5)) +
    point(0, 0; name="O") +
    circle(point(0, 0), 3)
```

### `do`-Block Syntax

For more complex constructions, use Julia's `do`-block:

```julia
using JSXGraph

b = board("shapes", xlim=(-5, 5), ylim=(-5, 5)) do b
    push!(b, point(0, 0; name="Center"))
    push!(b, circle(point(0, 0), 2; color="blue"))
    push!(b, polygon(point(-1, -1), point(1, -1), point(0, 1)))
end
```

## Plotting Functions

### One-Liner with `plot`

The simplest way to plot a function:

```julia
using JSXGraph

b = plot(sin, (-2π, 2π))
```

This creates a board with a function graph and sensible defaults.

### Function Graphs on a Board

For more control, use `functiongraph` directly:

```julia
using JSXGraph

b = board("trig", xlim=(-7, 7), ylim=(-2, 2)) do b
    push!(b, functiongraph(sin; color="blue"))
    push!(b, functiongraph(cos; color="red"))
end
```

Julia functions like `sin`, `cos`, `exp` are automatically converted to their
JavaScript `Math.*` equivalents. For custom expressions, use Julia expressions:

```julia
fg = functiongraph(:(x -> x^2 - 1); color="purple")
```

### Convenience Functions

JSXGraph.jl provides four high-level plotting functions that create complete
boards in a single call:

```julia
using JSXGraph

# Scatter plot
b = scatter([1, 2, 3, 4, 5], [1, 4, 9, 16, 25])

# Parametric curve (ellipse)
b = parametric(cos, sin, (0, 2π))

# Implicit curve (unit circle: x² + y² - 1 = 0)
b = implicit(:((x, y) -> x^2 + y^2 - 1))

# Polar curve (cardioid)
b = polar(:(θ -> 1 + cos(θ)))
```

## Interactive Elements

JSXGraph excels at interactivity. Add sliders and dependent elements:

```julia
using JSXGraph

b = board("interactive", xlim=(-5, 5), ylim=(-5, 5)) do b
    s = slider([0, -4], [4, -4], [0.5, 1, 3]; name="a")
    push!(b, s)
    push!(b, functiongraph(@jsf x -> s * x^2; color="blue"))
end
```

Draggable points and all dependent constructions update in real time in the
browser — no server round-trip is needed.

## Styling with Aliases

JSXGraph.jl accepts Plots.jl-compatible keyword aliases so you can use familiar
names:

```julia
# These are all equivalent:
p = point(1, 2; strokeColor="red")
p = point(1, 2; color="red")
p = point(1, 2; col="red")
```

Common aliases:

| Alias | JSXGraph attribute |
|---|---|
| `color` / `col` | `strokeColor` |
| `linewidth` / `lw` | `strokeWidth` |
| `fillcolor` / `fill` | `fillColor` |
| `opacity` / `alpha` | `strokeOpacity` + `fillOpacity` |
| `linestyle` / `ls` | `dash` |
| `markersize` / `ms` | `size` (for points) |
| `label` | `name` |

See the [Attribute Aliases](aliases.md) page for the full list.

## Using Themes

Switch the visual style of all elements at once:

```julia
using JSXGraph

# Use the dark theme for this board
set_theme!(:dark)
b = Board("dark", xlim=(-5, 5), ylim=(-5, 5))
push!(b, point(0, 0), functiongraph(sin))
reset_theme!()

# Or use a scoped theme
with_theme(:publication) do
    b = plot(cos, (-π, π))
end
```

Three built-in themes are available: `:default`, `:dark`, and `:publication`.
You can also load custom themes from TOML or JSON files.
See the [Themes](themes.md) page for details.

## The `@jsf` Macro

The [`@jsf`](@ref) macro converts Julia lambda expressions to JavaScript at
compile time:

```julia
using JSXGraph

f = @jsf x -> sin(x) + x^2
fg = functiongraph(f; color="green")
```

It supports arithmetic, math functions, constants (`π`, `ℯ`), comparisons, and
`ifelse`. Unsupported constructs (loops, try/catch, multi-statement bodies)
produce a clear compile-time error.

### Named Functions & Dependencies

When one JavaScript function needs to call another, use [`@named_jsf`](@ref) and
[`with_deps`](@ref):

```julia
using JSXGraph

@named_jsf square(x) = x^2
main = with_deps(@jsf(x -> square(x) + 1), square)
b = Board("b") + functiongraph(main)
```

The renderer emits all helper definitions in topological order before the
elements that use them. See [Geometric Elements](elements.md) for details.

## Saving to HTML

Export a board to a standalone HTML file:

```julia
using JSXGraph

b = plot(sin, (-5, 5))
save("sine_plot.html", b)
```

The generated file embeds all JSXGraph assets inline and can be opened in any
browser without an internet connection.

## Ecosystem Integration

### Tables.jl

Plot data directly from any Tables.jl-compatible source:

```julia
using JSXGraph, Tables

data = (x=[1, 2, 3, 4], y=[1, 4, 9, 16])
b = scatter(data, :x, :y)
b = plot(data; color="blue")  # line plot
```

### Unitful.jl

Pass quantities with units — axis labels are annotated automatically:

```julia
using JSXGraph, Unitful

x = [1.0, 2.0, 3.0]u"m"
y = [0.5, 1.0, 1.5]u"s"
b = scatter(x, y)  # axes: "x (m)", "y (s)"
```

### Colors.jl

Use any Colors.jl color type:

```julia
using JSXGraph, Colors

p = point(1, 2; color=colorant"dodgerblue")
p = point(3, 4; color=RGB(0.2, 0.8, 0.3))
```

## Next Steps

- Browse the [Geometric Elements](elements.md) page for the full list of element constructors
- See [HTML Generation](html_generation.md) for details on `html_string`, `html_page`, and `html_fragment`
- Read the [Display Protocol](display.md) page for rendering in different environments
- Check the [Themes](themes.md) page for custom theme creation
- Explore the [Attribute Aliases](aliases.md) reference
