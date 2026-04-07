"""
$(TYPEDEF)

Abstract supertype for all JSXGraph elements that can be placed on a board.

All concrete element types (points, lines, circles, curves, sliders, etc.)
are subtypes of `AbstractJSXElement`.
"""
abstract type AbstractJSXElement end

"""
$(TYPEDEF)

Container representing an interactive JSXGraph board.

Holds a collection of elements and board-level configuration such as
axis limits, grid settings, and visual attributes.

# Fields
$(TYPEDFIELDS)
"""
mutable struct Board
    "Unique identifier for the HTML div element"
    id::String
    "Ordered collection of elements on this board"
    elements::Vector{AbstractJSXElement}
    "Board-level configuration options"
    options::Dict{String,Any}
end

"""
$(SIGNATURES)

Create a Board with keyword arguments for common options.

Auto-generates a unique `id` if an empty string is provided.

# Arguments
- `id::String`: Board identifier (auto-generated if empty)
- `xlim`: x-axis range as `(xmin, xmax)`
- `ylim`: y-axis range as `(ymin, ymax)`
- `axis`: show axes (default: `true`)
- `grid`: show grid (default: `false`)
- `width`: board width in pixels (default: `500`)
- `height`: board height in pixels (default: `500`)
- Additional keyword arguments are stored directly in `options`
"""
function Board(
    id::String;
    xlim::Union{Nothing,Tuple{Real,Real}}=nothing,
    ylim::Union{Nothing,Tuple{Real,Real}}=nothing,
    axis::Bool=true,
    grid::Bool=false,
    width::Int=500,
    height::Int=500,
    kwargs...,
)
    # Auto-generate id if empty
    if isempty(id)
        id = "jxg_" * randstring(8)
    end

    options = Dict{String,Any}("axis" => axis, "width" => width, "height" => height)

    if grid
        options["grid"] = true
    end

    # Build boundingbox from xlim/ylim
    if xlim !== nothing || ylim !== nothing
        xmin = xlim !== nothing ? xlim[1] : -5
        xmax = xlim !== nothing ? xlim[2] : 5
        ymin = ylim !== nothing ? ylim[1] : -5
        ymax = ylim !== nothing ? ylim[2] : 5
        options["boundingbox"] = [xmin, ymax, xmax, ymin]
    end

    # Merge defaults for options not explicitly set
    if !haskey(options, "boundingbox")
        options["boundingbox"] = [-5, 5, 5, -5]
    end
    if !haskey(options, "showNavigation")
        options["showNavigation"] = false
    end
    if !haskey(options, "showCopyright")
        options["showCopyright"] = false
    end

    # Store additional keyword arguments
    for (k, v) in kwargs
        options[string(k)] = v
    end

    # Apply board theme defaults (lowest priority — don't override explicit options)
    for (k, v) in board_theme_defaults()
        if !haskey(options, k)
            options[k] = v
        end
    end

    return Board(id, AbstractJSXElement[], options)
end

"""
$(TYPEDEF)

Represents a JSXGraph 3D viewport that can contain 3D elements.

A `View3D` is added to a [`Board`](@ref) like any other element, but 3D elements
(`point3d`, `line3d`, `curve3d`, etc.) are created on the view rather than
directly on the board.

$(TYPEDFIELDS)
"""
mutable struct View3D <: AbstractJSXElement
    "Always \"view3d\""
    type_name::String
    "Positional arguments: [position, size, ranges]"
    parents::Vector{Any}
    "Visual and behavioral attributes"
    attributes::Dict{String,Any}
    "3D elements contained in this view"
    elements::Vector{AbstractJSXElement}
end
