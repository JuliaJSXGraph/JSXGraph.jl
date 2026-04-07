module JSXGraphUnitfulExt

using JSXGraph
using Unitful
using Unitful: ustrip, unit, dimension, uconvert, Quantity, Units

# --- Unitful.jl integration (REQ-ECO-002) ---

"""
    _unit_label(u)

Return a human-readable label string for a Unitful unit.
"""
function _unit_label(u::Units)
    return string(u)
end

"""
    _axis_label(name::String, u::Units)

Create an axis label string like `"x (m)"` or `"y (kg)"`.
"""
function _axis_label(name::String, u::Units)
    ulabel = _unit_label(u)
    return isempty(ulabel) ? name : "$name ($ulabel)"
end

"""
    _set_axis_labels!(board::Board; xlabel=nothing, ylabel=nothing)

Configure default axis labels on a Board via the `defaultAxes` option.
"""
function _set_axis_labels!(board::Board; xlabel=nothing, ylabel=nothing)
    if xlabel !== nothing || ylabel !== nothing
        da = get(board.options, "defaultAxes", Dict{String,Any}())
        if xlabel !== nothing
            x_opts = get(da, "x", Dict{String,Any}())
            x_opts["name"] = xlabel
            x_opts["withLabel"] = true
            x_opts["label"] = get(x_opts, "label", Dict{String,Any}())
            x_opts["label"]["position"] = "rt"
            x_opts["label"]["offset"] = [0, 15]
            da["x"] = x_opts
        end
        if ylabel !== nothing
            y_opts = get(da, "y", Dict{String,Any}())
            y_opts["name"] = ylabel
            y_opts["withLabel"] = true
            y_opts["label"] = get(y_opts, "label", Dict{String,Any}())
            y_opts["label"]["position"] = "rt"
            y_opts["label"]["offset"] = [15, 0]
            da["y"] = y_opts
        end
        board.options["defaultAxes"] = da
    end
    return board
end

# --- point with Unitful quantities ---

"""
    point(x::Quantity, y::Quantity; kwargs...)

Create a point from Unitful quantities, stripping units to plain numbers.
"""
function JSXGraph.point(x::Quantity, y::Quantity; kwargs...)
    return JSXGraph.point(ustrip(x), ustrip(y); kwargs...)
end

# --- scatter with Unitful vectors ---

"""
    scatter(x::AbstractVector{<:Quantity}, y::AbstractVector{<:Quantity}; xlabel="x", ylabel="y", kwargs...)

Create a scatter plot from Unitful vectors, with automatic axis labels showing units.

Units are stripped from the values and displayed as axis annotations.
All values in each vector must have compatible units (converted to the unit of the first element).

# Examples
```julia
using JSXGraph, Unitful

x = [1.0, 2.0, 3.0, 4.0]u"m"
y = [0.5, 1.0, 1.5, 2.0]u"s"
b = scatter(x, y)  # axes labeled "x (m)" and "y (s)"
```
"""
function JSXGraph.scatter(x::AbstractVector{<:Quantity}, y::AbstractVector{<:Quantity};
                          xlabel::String="x", ylabel::String="y",
                          kwargs...)
    # Extract units from first element
    xu = unit(first(x))
    yu = unit(first(y))

    # Convert all elements to the same unit and strip
    x_stripped = [ustrip(xu, xi) for xi in x]
    y_stripped = [ustrip(yu, yi) for yi in y]

    # Create scatter with plain numbers
    board = JSXGraph.scatter(x_stripped, y_stripped; kwargs...)

    # Add axis labels with units
    _set_axis_labels!(board; xlabel=_axis_label(xlabel, xu), ylabel=_axis_label(ylabel, yu))
    return board
end

# --- plot with Unitful domain ---

"""
    plot(f, domain::Tuple{Quantity,Quantity}; xlabel="x", ylabel="y", kwargs...)

Create a function plot with a Unitful domain, stripping units and adding axis labels.

# Examples
```julia
using JSXGraph, Unitful

b = plot(sin, (-5u"m", 5u"m"); xlabel="distance")
```
"""
function JSXGraph.plot(f, domain::Tuple{Quantity,Quantity};
                       xlabel::String="x", ylabel::String="y",
                       kwargs...)
    xu = unit(domain[1])

    xmin = ustrip(xu, domain[1])
    xmax = ustrip(xu, domain[2])

    board = JSXGraph.plot(f, (xmin, xmax); kwargs...)
    _set_axis_labels!(board; xlabel=_axis_label(xlabel, xu))
    return board
end

# --- Board with Unitful xlim/ylim ---

"""
    Board(id; xlim::Tuple{Quantity,Quantity}, ylim::Tuple{Quantity,Quantity}, xlabel="x", ylabel="y", kwargs...)

Create a Board with Unitful axis limits, automatically stripping units and adding axis labels.

# Examples
```julia
using JSXGraph, Unitful

b = Board(""; xlim=(0u"m", 10u"m"), ylim=(0u"s", 5u"s"))
```
"""
function JSXGraph.Board(id::String,
                        xlim::Tuple{Quantity,Quantity},
                        ylim::Tuple{Quantity,Quantity};
                        xlabel::String="x", ylabel::String="y",
                        kwargs...)
    xu = unit(xlim[1])
    yu = unit(ylim[1])

    xlim_stripped = (ustrip(xu, xlim[1]), ustrip(xu, xlim[2]))
    ylim_stripped = (ustrip(yu, ylim[1]), ustrip(yu, ylim[2]))

    board = JSXGraph.Board(id; xlim=xlim_stripped, ylim=ylim_stripped, kwargs...)
    _set_axis_labels!(board; xlabel=_axis_label(xlabel, xu), ylabel=_axis_label(ylabel, yu))
    return board
end

end # module JSXGraphUnitfulExt
