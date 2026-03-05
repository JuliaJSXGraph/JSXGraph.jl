module JSXGraphTablesExt

using JSXGraph
using Tables

# --- Tables.jl data ingestion (REQ-ECO-001) ---

"""
    scatter(table, xcol::Symbol, ycol::Symbol; kwargs...)

Create a scatter plot from columns of a `Tables.jl`-compatible object.

# Arguments
- `table`: any Tables.jl-compatible data source (e.g., DataFrame, NamedTuple of vectors)
- `xcol::Symbol`: column name for x-coordinates
- `ycol::Symbol`: column name for y-coordinates
- Additional keyword arguments are forwarded to [`scatter`](@ref)

# Examples
```julia
using JSXGraph, DataFrames

df = DataFrame(x=[1, 2, 3, 4], y=[1, 4, 9, 16])
b = scatter(df, :x, :y)
b = scatter(df, :x, :y; color="red", size=4)
```
"""
function JSXGraph.scatter(table, xcol::Symbol, ycol::Symbol; kwargs...)
    if !Tables.istable(table)
        throw(ArgumentError("First argument must be a Tables.jl-compatible object"))
    end
    cols = Tables.columns(table)
    if !Tables.columnaccess(table) && !hasproperty(cols, xcol)
        throw(ArgumentError("Column :$xcol not found in table"))
    end
    if !Tables.columnaccess(table) && !hasproperty(cols, ycol)
        throw(ArgumentError("Column :$ycol not found in table"))
    end
    x = collect(Float64, Tables.getcolumn(cols, xcol))
    y = collect(Float64, Tables.getcolumn(cols, ycol))
    return JSXGraph.scatter(x, y; kwargs...)
end

"""
    scatter(table; x=nothing, y=nothing, kwargs...)

Create a scatter plot from a `Tables.jl`-compatible object.

When `x` and `y` column names are not specified, uses the first two columns.

# Examples
```julia
using JSXGraph

data = (x=[1, 2, 3], y=[1, 4, 9])
b = scatter(data)              # uses first two columns
b = scatter(data; x=:x, y=:y) # explicit column names
```
"""
function JSXGraph.scatter(table; x::Union{Nothing,Symbol}=nothing,
                          y::Union{Nothing,Symbol}=nothing, kwargs...)
    if !Tables.istable(table)
        # Fall through — not a table, let Julia dispatch handle it
        throw(MethodError(JSXGraph.scatter, (table,)))
    end
    cols = Tables.columns(table)
    colnames = Tables.columnnames(cols)
    colnames_vec = collect(colnames)

    if length(colnames_vec) < 2
        throw(ArgumentError("Table must have at least 2 columns, got $(length(colnames_vec))"))
    end

    xcol = x === nothing ? colnames_vec[1] : x
    ycol = y === nothing ? colnames_vec[2] : y

    return JSXGraph.scatter(table, xcol, ycol; kwargs...)
end

"""
    plot(table, xcol::Symbol, ycol::Symbol; kwargs...)

Create a line plot from columns of a `Tables.jl`-compatible object.

The data points are rendered as a parametric curve connecting `(x[i], y[i])` pairs
in order, using JSXGraph's `curve` element with data arrays.

# Arguments
- `table`: any Tables.jl-compatible data source
- `xcol::Symbol`: column name for x-coordinates
- `ycol::Symbol`: column name for y-coordinates
- `xlim`: x-axis range (default: auto-computed with 10% padding)
- `ylim`: y-axis range (default: auto-computed with 10% padding)
- Additional keyword arguments are forwarded to the curve element

# Examples
```julia
using JSXGraph, DataFrames

df = DataFrame(t=[0, 1, 2, 3], val=[0.0, 0.8, 0.9, 0.2])
b = plot(df, :t, :val)
b = plot(df, :t, :val; color="blue", strokeWidth=3)
```
"""
function JSXGraph.plot(table, xcol::Symbol, ycol::Symbol;
                       xlim::Union{Nothing,Tuple{Real,Real}}=nothing,
                       ylim::Union{Nothing,Tuple{Real,Real}}=nothing,
                       kwargs...)
    if !Tables.istable(table)
        throw(ArgumentError("First argument must be a Tables.jl-compatible object"))
    end
    cols = Tables.columns(table)
    x = collect(Float64, Tables.getcolumn(cols, xcol))
    y = collect(Float64, Tables.getcolumn(cols, ycol))

    if isempty(x)
        throw(ArgumentError("Table columns must not be empty"))
    end

    # Auto-compute axis limits with 10% padding
    if xlim === nothing
        xmin, xmax = extrema(x)
        pad = xmin == xmax ? 1.0 : 0.1 * (xmax - xmin)
        xlim = (xmin - pad, xmax + pad)
    end
    if ylim === nothing
        ymin, ymax = extrema(y)
        pad = ymin == ymax ? 1.0 : 0.1 * (ymax - ymin)
        ylim = (ymin - pad, ymax + pad)
    end

    b = Board(""; xlim=xlim, ylim=ylim)
    # Use curve element with data arrays for a connected line plot
    c = JSXGraph._create_element("curve", (x, y), kwargs)
    push!(b, c)
    return b
end

"""
    plot(table; x=nothing, y=nothing, kwargs...)

Create a line plot from a `Tables.jl`-compatible object.

When `x` and `y` column names are not specified, uses the first two columns.

# Examples
```julia
using JSXGraph

data = (x=[0, 1, 2, 3], y=[0.0, 0.8, 0.9, 0.2])
b = plot(data)
b = plot(data; x=:x, y=:y)
```
"""
function JSXGraph.plot(table; x::Union{Nothing,Symbol}=nothing,
                       y::Union{Nothing,Symbol}=nothing, kwargs...)
    if !Tables.istable(table)
        throw(MethodError(JSXGraph.plot, (table,)))
    end
    cols = Tables.columns(table)
    colnames = Tables.columnnames(cols)
    colnames_vec = collect(colnames)

    if length(colnames_vec) < 2
        throw(ArgumentError("Table must have at least 2 columns, got $(length(colnames_vec))"))
    end

    xcol = x === nothing ? colnames_vec[1] : x
    ycol = y === nothing ? colnames_vec[2] : y

    return JSXGraph.plot(table, xcol, ycol; kwargs...)
end

end # module JSXGraphTablesExt
