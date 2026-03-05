# Recipe system integration (REQ-ECO-020, REQ-ECO-021)
#
# Bridges JSXGraphRecipesBase.jl element specifications into concrete JSXGraph
# board elements.  The public entry points are `plot!` (mutating) and the
# `plot(::Board, obj)` / `board + obj` overloads.

using JSXGraphRecipesBase: ElementSpec, apply_recipe, has_recipe

# Re-export JSXGraphRecipesBase public API
using JSXGraphRecipesBase: @jsxrecipe

"""
$(SIGNATURES)

Convert a single [`ElementSpec`](@ref) into a [`JSXElement`](@ref), substituting
any `ElementSpec` parents with already-realised `JSXElement` objects tracked in
`spec_map`.

This is an internal helper used by [`realize_specs`](@ref).
"""
function _realize_one(spec::ElementSpec, spec_map::Dict{UInt,JSXElement})
    # Replace ElementSpec parents with their realised JSXElement counterparts
    realized_parents = map(spec.parents) do p
        if p isa ElementSpec
            id = objectid(p)
            if haskey(spec_map, id)
                return spec_map[id]
            else
                error("ElementSpec referenced as parent has not been realised yet. " *
                      "Ensure parent specs appear before dependent specs in the recipe output.")
            end
        end
        return p
    end

    # Convert Symbol kwargs to the (Symbol => Any)... form expected by _create_element
    type_name = String(spec.element_type)
    kwargs = Tuple(k => v for (k, v) in spec.attributes)
    elem = _create_element(type_name, Tuple(realized_parents), kwargs)

    # Track so that later specs can reference this one
    spec_map[objectid(spec)] = elem

    return elem
end

"""
$(SIGNATURES)

Convert a vector of [`ElementSpec`](@ref) objects (as returned by
[`apply_recipe`](@ref)) into concrete [`JSXElement`](@ref) objects.

Specs are processed in order; each spec may reference earlier specs as parents.

# Returns
`Vector{JSXElement}` — the realised elements, ready to be added to a board.
"""
function realize_specs(specs::AbstractVector{ElementSpec})
    spec_map = Dict{UInt,JSXElement}()
    elements = JSXElement[]
    for spec in specs
        elem = _realize_one(spec, spec_map)
        push!(elements, elem)
    end
    return elements
end

"""
$(SIGNATURES)

Add elements to `board` by applying the [`@jsxrecipe`](@ref) registered for
`typeof(obj)`.

# Arguments
- `board::Board`: target board (mutated in place)
- `obj`: any object whose type has a registered recipe
- `kwargs...`: forwarded to [`apply_recipe`](@ref)

# Returns
The `board`, with the recipe's elements appended.

# Throws
`ArgumentError` if no recipe is defined for `typeof(obj)`.

# Example
```julia
b = Board("")
plot!(b, Triangle((0,0), (3,0), (1.5,2.5)); color="red")
```
"""
function plot!(board::Board, obj; kwargs...)
    if !has_recipe(obj)
        throw(ArgumentError(
            "No JSXGraph recipe defined for $(typeof(obj)). " *
            "Define one with @jsxrecipe from JSXGraphRecipesBase."
        ))
    end
    specs = apply_recipe(obj; kwargs...)
    elements = realize_specs(specs)
    for elem in elements
        push!(board, elem)
    end
    return board
end

"""
$(SIGNATURES)

Create a new board containing the elements produced by the [`@jsxrecipe`](@ref)
registered for `typeof(obj)`.

This non-mutating overload creates a fresh [`Board`](@ref) and populates it via
[`plot!`](@ref).

# Arguments
- `board::Board`: source board (not modified — a copy is used)
- `obj`: any object whose type has a registered recipe
- `kwargs...`: forwarded to [`apply_recipe`](@ref)

# Returns
A new `Board` with the recipe's elements appended.

# Example
```julia
b = Board(""; xlim=(-5,5), ylim=(-5,5))
b2 = plot(b, Circle2D(0, 0, 2); color="blue")
```
"""
function plot(board::Board, obj; kwargs...)
    new_board = Board(board.id, copy(board.elements), copy(board.options))
    return plot!(new_board, obj; kwargs...)
end

"""
$(SIGNATURES)

Create a board from a recipe object using the `+` operator.

# Example
```julia
b = Board(""; xlim=(-5,5))
b2 = b + my_triangle
```
"""
function Base.:+(board::Board, obj)
    if has_recipe(obj)
        return plot(board, obj)
    end
    throw(ArgumentError(
        "Cannot add $(typeof(obj)) to a Board. " *
        "Define a recipe with @jsxrecipe or use a JSXElement."
    ))
end
