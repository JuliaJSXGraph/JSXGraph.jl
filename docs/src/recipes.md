# Recipe System

The recipe system allows external packages to define how their custom types are
rendered on a JSXGraph board **without depending on JSXGraph.jl directly**.
Instead, they depend on the lightweight
[JSXGraphRecipesBase.jl](https://github.com/s-celles/JSXGraphRecipesBase.jl)
interface package.

## Overview

The recipe workflow follows three steps:

1. A package defines a custom type (e.g., `Triangle`).
2. A recipe is registered with [`@jsxrecipe`](@ref), returning a list of [`ElementSpec`](@ref) objects.
3. When the user calls [`plot!`](@ref) (or `+`) with an instance of that type, JSXGraph.jl converts the specs into real board elements.

## Quick Start

### Defining a Recipe

```julia
using JSXGraphRecipesBase

struct Triangle
    A::Tuple{Float64, Float64}
    B::Tuple{Float64, Float64}
    C::Tuple{Float64, Float64}
end

@jsxrecipe function f(t::Triangle; color="blue")
    p1 = ElementSpec(:point, t.A[1], t.A[2]; name="A")
    p2 = ElementSpec(:point, t.B[1], t.B[2]; name="B")
    p3 = ElementSpec(:point, t.C[1], t.C[2]; name="C")
    [p1, p2, p3, ElementSpec(:polygon, p1, p2, p3; strokeColor=color)]
end
```

The `@jsxrecipe` macro turns the function into a method of
[`apply_recipe`](@ref), dispatching on the annotated argument type.

### Using a Recipe

```julia
using JSXGraph

b = Board(""; xlim=(-2, 5), ylim=(-2, 5))
tri = Triangle((0.0, 0.0), (3.0, 0.0), (1.5, 2.5))

# Mutating — add elements in-place
plot!(b, tri; color="red")

# Non-mutating — returns a new board
b2 = plot(b, tri)

# Operator syntax
b3 = b + tri
```

### Do-block Syntax

Recipes compose naturally with the `do`-block board constructor:

```julia
b = board(xlim=(-2, 5), ylim=(-2, 5)) do b
    plot!(b, Triangle((0.0, 0.0), (3.0, 0.0), (1.5, 2.5)); color="red")
    plot!(b, Triangle((1.0, 1.0), (4.0, 1.0), (2.5, 3.5)); color="blue")
end
```

## Element Dependencies

An [`ElementSpec`](@ref) can reference another `ElementSpec` as a parent. When
realized, JSXGraph.jl substitutes the references with the corresponding
[`JSXElement`](@ref) objects. Specs are processed in order, so **parent specs
must appear before dependent specs** in the returned vector.

```julia
@jsxrecipe function f(c::Circle2D; color="black")
    center = ElementSpec(:point, c.cx, c.cy; visible=false)
    [center, ElementSpec(:circle, center, c.r; strokeColor=color)]
end
```

## Attribute Aliases

Recipe keyword arguments are forwarded through the standard
[alias resolution system](aliases.md), so Plots.jl-friendly
names work:

```julia
plot!(b, my_obj; color="red", lw=3, alpha=0.5)
```

## Checking for Recipes

```julia
has_recipe(Triangle)      # true
has_recipe(my_triangle)   # true (instance check)
has_recipe(Int)           # false
```

## API Reference

### JSXGraphRecipesBase

```@docs
ElementSpec
@jsxrecipe
apply_recipe
has_recipe
```

### JSXGraph.jl Integration

```@docs
plot!
realize_specs
```
