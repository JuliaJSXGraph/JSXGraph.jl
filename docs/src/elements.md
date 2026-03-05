# Geometric Elements

JSXGraph.jl provides Julia constructors for all JSXGraph element types. Elements are created as `JSXElement` objects and added to a `Board` for rendering.

## Element Creation Pattern

All element constructors follow the same pattern:

```julia
constructor(parents...; attributes...) → JSXElement
```

Parents define the geometry (coordinates, references to other elements), and keyword arguments become visual/behavioral attributes.

## Geometric Primitives

14 constructors for basic geometric shapes:

```julia
using JSXGraph

# Points
p1 = point(-1, 0)
p2 = point(1, 0; color="red", size=4)

# Lines and segments
l = line(p1, p2)
s = segment(p1, p2; strokeWidth=3)
a = arrow(p1, p2)

# Circles
c = circle(p1, 3)             # center + radius
c2 = circle(p1, p2)           # center + point on circle

# Arcs and sectors
a = arc(p1, p2, point(0, 1))
s = sector(p1, p2, point(0, 1))

# Polygons
poly = polygon(p1, p2, point(0, 1))
reg = regularpolygon(p1, p2, 5)    # 5-sided regular polygon

# Conics
e = ellipse(p1, p2, point(0, 2))
h = hyperbola(p1, p2, point(0, 2))
p = parabola(p1, l)
```

See [`point`](@ref), [`line`](@ref), [`circle`](@ref), [`polygon`](@ref) in the API Reference.

## Composition & Transformation Elements

9 constructors for grouping, transformations, axes, and grids:

```julia
using JSXGraph

p1 = point(0, 0)
p2 = point(1, 0)
p3 = point(0, 1)
l = line(p1, p2)

# Group elements for collective operations
g = group(p1, p2, l)

# Transformations (translate, rotate, scale, reflect, shear, generic)
t = transformation("translate", 2, 3)
t = transformation("rotate", π/4)
t = transformation("rotate", π/4, 1, 1)   # rotate around (1,1)

# Convenience constructors for common transformations
r = reflection(l)              # reflect across a line
rot = rotation(p1, π/4)       # rotate around a point
tr = translation(2, 3)        # translate by (dx, dy)

# Grid overlay
gr = grid()
gr = grid(; majorStep=[1, 1])

# Custom axes
ax = axis(p1, point(1, 0); name="x")
ay = axis(p1, point(0, 1); name="y")

# Tick marks on an axis
tk = ticks(ax, 1.0; minorTicks=4, drawLabels=true)

# Legend
fg1 = functiongraph(sin; color="blue")
fg2 = functiongraph(cos; color="red")
leg = legend(fg1, fg2; labels=["sin", "cos"])
```

See [`group`](@ref), [`transformation`](@ref), [`reflection`](@ref), [`rotation`](@ref), [`translation`](@ref), [`grid`](@ref), [`axis`](@ref), [`ticks`](@ref), [`legend`](@ref) in the API Reference.

## Analytic Elements

11 constructors for mathematical functions and calculus:

```julia
using JSXGraph

# Function graphs (Julia functions auto-converted to JavaScript)
fg = functiongraph(sin)
fg2 = functiongraph(:(x -> x^2 + 1); color="blue")

# Parametric curves
c = curve(cos, sin, 0, 2π)

# Calculus constructions
d = derivative(fg)
i = integral(fg, -2, 2)
rs = riemannsum(sin, 10, "lower"; a=0, b=3.14)

# Slope and vector fields
sf = slopefield(:(x -> x^2))
```

Julia functions like `sin`, `cos`, `exp` are automatically converted to their JavaScript `Math.*` equivalents.

## Interactive Controls

8 constructors for user interface elements:

```julia
using JSXGraph

# Slider with [min, start, max]
s = slider([0, -3], [4, -3], [1, 2, 5]; name="a")

# Text and labels
t = text(0, 4, "Hello World")

# Buttons and inputs
btn = button(0, -4, "Reset", "handler()")
chk = checkbox(0, -5, "Show Grid")
inp = input(0, -6, "0", "Value")
```

## Board Composition

Add elements to boards using `push!` (mutating) or `+` (non-mutating):

```julia
using JSXGraph

board = Board("myboard", xlim=(-5, 5), ylim=(-5, 5))

# Mutating: modifies board in place
push!(board, point(1, 2))
push!(board, point(3, 4), line(point(0, 0), point(1, 1)))

# Non-mutating: returns a new board
new_board = board + point(5, 6)

# Chaining
result = Board("b") + point(0, 0) + point(1, 1) + point(2, 2)
```

### `do`-Block Syntax

Use Julia's `do`-block syntax with [`board`](@ref) for idiomatic board construction:

```julia
using JSXGraph

b = board("myboard", xlim=(-5, 5), ylim=(-5, 5)) do b
    push!(b, point(1, 2; name="A"))
    push!(b, point(3, 4; name="B"))
    push!(b, line(point(0, 0), point(1, 1)))
end

# With auto-generated id and default options
b = board(xlim=(-10, 10)) do b
    push!(b, functiongraph(sin; color="blue"))
    push!(b, functiongraph(cos; color="red"))
end
```

See [`board`](@ref) in the API Reference.

## High-Level Plot

Create a complete board with a function graph in one line:

```julia
using JSXGraph

# One-liner function plotting
b = plot(sin, (-5, 5))
b = plot(cos, (0, 2π); color="blue", strokeWidth=3)
```

See [`plot`](@ref) in the API Reference.

## Convenience Functions

Four high-level functions create complete boards for common plot types:

### Scatter Plots

```julia
using JSXGraph

# Basic scatter
b = scatter([1, 2, 3, 4], [1, 4, 9, 16])

# With styling (axis limits auto-computed with 10% padding)
b = scatter([0.0, 1.0, 2.0], [0.0, 1.0, 0.0]; color="red", size=4)

# Explicit axis limits
b = scatter([1, 2, 3], [1, 4, 9]; xlim=(0, 5), ylim=(0, 12))
```

### Parametric Curves

```julia
using JSXGraph

# Unit circle
b = parametric(cos, sin, (0, 2π))

# Ellipse with custom limits
b = parametric(:(t -> 3cos(t)), :(t -> 2sin(t)), (0, 2π);
               xlim=(-4, 4), ylim=(-3, 3), color="blue")
```

### Implicit Curves

```julia
using JSXGraph

# Unit circle: x² + y² - 1 = 0
b = implicit(:((x, y) -> x^2 + y^2 - 1))

# Ellipse with custom bounds
b = implicit(:((x, y) -> x^2/4 + y^2/9 - 1); xlim=(-3, 3), ylim=(-4, 4))
```

### Polar Curves

```julia
using JSXGraph

# Cardioid
b = polar(:(θ -> 1 + cos(θ)))

# Spiral over 4π
b = polar(:(θ -> θ), (0, 4π))

# Rose curve with styling
b = polar(:(θ -> cos(3θ)); color="magenta")
```

See [`scatter`](@ref), [`parametric`](@ref), [`implicit`](@ref), [`polar`](@ref) in the API Reference.

## Tables.jl Data Integration

When the [Tables.jl](https://github.com/JuliaTables/Tables.jl) package is loaded,
`scatter` and `plot` gain methods that accept any Tables.jl-compatible data source
(e.g., `DataFrame`, `NamedTuple` of vectors, vector of `NamedTuple`s).

### Scatter from Table

```julia
using JSXGraph, Tables

# NamedTuple of vectors (Tables.jl-compatible)
data = (x=[1, 2, 3, 4], y=[1, 4, 9, 16])

# Auto-detect first two columns
b = scatter(data)

# Explicit column names
b = scatter(data, :x, :y)
b = scatter(data; x=:x, y=:y; color="red")
```

### Line Plot from Table

```julia
using JSXGraph, Tables

data = (time=[0, 1, 2, 3, 4], value=[0.0, 0.8, 0.9, 0.5, 0.2])
b = plot(data, :time, :value)
b = plot(data; color="blue", strokeWidth=2)
```

Column selection defaults to the first two columns when `x` and `y` are not specified.
Works with any Tables.jl-compatible source including DataFrames, CSV files, and more.

## Unitful.jl Integration

When the [Unitful.jl](https://github.com/PainterQubits/Unitful.jl) package is loaded,
coordinates and ranges can include physical units. Units are automatically stripped for
plotting, and axis labels are annotated with the unit string.

### Scatter with Units

```julia
using JSXGraph, Unitful

x = [1.0, 2.0, 3.0, 4.0]u"m"
y = [0.5, 1.0, 1.5, 2.0]u"s"
b = scatter(x, y)  # axes labeled "x (m)" and "y (s)"

# Custom axis labels
b = scatter(x, y; xlabel="distance", ylabel="time")
# axes: "distance (m)" and "time (s)"
```

### Function Plot with Unitful Domain

```julia
using JSXGraph, Unitful

b = plot(sin, (-5u"m", 5u"m"); xlabel="distance")
```

### Board with Unitful Limits

```julia
using JSXGraph, Unitful

b = Board("myboard", (0u"km", 100u"km"), (0u"kg", 50u"kg");
          xlabel="distance", ylabel="mass")
```

Mixed compatible units are automatically converted to the unit of the first element
(e.g., `mm` values in a `m` vector are converted to meters).

## Julia-to-JavaScript Conversion

The [`julia_to_js`](@ref) function converts Julia expressions to JavaScript strings:

```julia
using JSXGraph

julia_to_js(:(sin(x)))          # "Math.sin(x)"
julia_to_js(:(x^2 + 1))        # "Math.pow(x, 2) + 1"
julia_to_js(:(x -> x^2))       # "function(x){return Math.pow(x, 2);}"
julia_to_js(sin)                # "function(x){return Math.sin(x);}"
```

Supported mappings include `sin`, `cos`, `tan`, `exp`, `log`, `sqrt`, `abs`, `floor`, `ceil`, and constants `π` → `Math.PI`, `ℯ` → `Math.E`.

### The `@jsf` Macro

The [`@jsf`](@ref) macro provides a convenient way to create [`JSFunction`](@ref)
objects directly from Julia expressions, with compile-time validation:

```julia
using JSXGraph

# Create a JSFunction from a lambda
f = @jsf x -> sin(x) + x^2

# Use directly in element constructors
fg = functiongraph(@jsf x -> cos(x) * exp(-x))

# Multi-argument functions
g = @jsf (x, y) -> x^2 + y^2

# Mathematical constants are handled
h = @jsf x -> sin(π * x)
```

**Supported constructs:** arithmetic (`+`, `-`, `*`, `/`, `^`), math functions
(`sin`, `cos`, `tan`, `exp`, `log`, `sqrt`, …), constants (`π`, `ℯ`), comparisons,
ternary `ifelse`, and anonymous functions.

**Unsupported constructs** (raise a compile-time error): `try`/`catch`, `for`/`while`
loops, array comprehensions, multi-statement function bodies, `let` blocks, `do` blocks,
`struct`/`module`/`import`/`using`/`export` definitions.

```julia
# These will raise ArgumentError at macro-expansion time:
@jsf x -> begin; y = x^2; y + 1; end   # multi-statement body
@jsf for i in 1:10; println(i); end     # for loop
```
