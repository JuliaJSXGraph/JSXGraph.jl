# Board composition operators

"""
$(SIGNATURES)

Add one or more elements to a board (mutating). Returns the board.
"""
function Base.push!(board::Board, elem::AbstractJSXElement)
    push!(board.elements, elem)
    return board
end

function Base.push!(board::Board, elems::AbstractJSXElement...)
    for elem in elems
        push!(board.elements, elem)
    end
    return board
end

"""
$(SIGNATURES)

Create a new board with the element added (non-mutating).

The original board is unchanged.
"""
function Base.:+(board::Board, elem::AbstractJSXElement)
    new_elements = copy(board.elements)
    push!(new_elements, elem)
    return Board(board.id, new_elements, copy(board.options))
end

# --- do-block syntax (REQ-API-004) ---

"""
$(SIGNATURES)

Create a board using Julia's `do`-block syntax.

Creates a [`Board`](@ref) with the given `id` and keyword arguments, passes it
to the callback function `f`, and returns the populated board.

# Arguments
- `f::Function`: callback that receives the board and populates it with elements
- `id::String`: board identifier (auto-generated if empty, default: `""`)
- `xlim`, `ylim`, `axis`, `grid`, `width`, `height`: forwarded to [`Board`](@ref)

# Examples
```julia
b = board("myboard", xlim=(-5, 5), ylim=(-5, 5)) do b
    push!(b, point(1, 2))
    push!(b, point(3, 4))
    push!(b, line(point(0, 0), point(1, 1)))
end

# With default auto-generated id
b = board(xlim=(-10, 10)) do b
    push!(b, functiongraph(sin; color="blue"))
    push!(b, functiongraph(cos; color="red"))
end
```
"""
function board(f::Function, id::String=""; kwargs...)
    b = Board(id; kwargs...)
    f(b)
    return b
end

"""
$(SIGNATURES)

Create a board with a function graph in a single call.

# Arguments
- `f`: Julia function or expression to plot
- `domain`: x-axis range as `(xmin, xmax)`
- Additional keyword arguments are passed to the `functiongraph` element
"""
function plot(f, domain::Tuple{Real,Real}; kwargs...)
    xmin, xmax = domain
    if xmin == xmax
        throw(ArgumentError("Domain must have non-zero width, got ($xmin, $xmax)"))
    end
    board = Board(""; xlim=(xmin, xmax))
    fg = functiongraph(f; kwargs...)
    push!(board, fg)
    return board
end

# --- Convenience functions (REQ-API-002) ---

"""
$(SIGNATURES)

Create a board with scatter points for each pair `(x[i], y[i])`.

# Arguments
- `x`: vector of x-coordinates
- `y`: vector of y-coordinates
- `xlim`: x-axis range (default: auto-computed with 10% padding)
- `ylim`: y-axis range (default: auto-computed with 10% padding)
- Additional keyword arguments are passed to each `point` element

# Examples
```julia
b = scatter([1, 2, 3, 4], [1, 4, 9, 16])
b = scatter([0.0, 1.0, 2.0], [0.0, 1.0, 0.0]; color="red", size=4)
```
"""
function scatter(x::AbstractVector{<:Real}, y::AbstractVector{<:Real};
                 xlim::Union{Nothing,Tuple{Real,Real}}=nothing,
                 ylim::Union{Nothing,Tuple{Real,Real}}=nothing,
                 kwargs...)
    if length(x) != length(y)
        throw(ArgumentError("x and y must have the same length, got $(length(x)) and $(length(y))"))
    end
    if isempty(x)
        throw(ArgumentError("x and y must not be empty"))
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

    board = Board(""; xlim=xlim, ylim=ylim)
    for (xi, yi) in zip(x, y)
        push!(board, point(xi, yi; kwargs...))
    end
    return board
end

"""
$(SIGNATURES)

Create a board with a parametric curve `(fx(t), fy(t))` over `t_range`.

# Arguments
- `fx`: function or expression for x-coordinate
- `fy`: function or expression for y-coordinate
- `t_range`: parameter range as `(t_start, t_end)`
- `xlim`: x-axis range (default: `(-5, 5)`)
- `ylim`: y-axis range (default: `(-5, 5)`)
- Additional keyword arguments are passed to the `curve` element

# Examples
```julia
b = parametric(cos, sin, (0, 2π))
b = parametric(:(t -> 2cos(t)), :(t -> 3sin(t)), (0, 2π); color="blue")
```
"""
function parametric(fx, fy, t_range::Tuple{Real,Real};
                    xlim::Tuple{Real,Real}=(-5, 5),
                    ylim::Tuple{Real,Real}=(-5, 5),
                    kwargs...)
    t_start, t_end = t_range
    if t_start == t_end
        throw(ArgumentError("Parameter range must have non-zero width, got ($t_start, $t_end)"))
    end
    board = Board(""; xlim=xlim, ylim=ylim)
    c = curve(fx, fy, t_start, t_end; kwargs...)
    push!(board, c)
    return board
end

"""
$(SIGNATURES)

Create a board with an implicit curve `F(x, y) = 0`.

# Arguments
- `F`: function or expression of two variables defining the implicit curve
- `xlim`: x-axis range (default: `(-5, 5)`)
- `ylim`: y-axis range (default: `(-5, 5)`)
- Additional keyword arguments are passed to the `implicitcurve` element

# Examples
```julia
b = implicit(:((x, y) -> x^2 + y^2 - 1))
b = implicit(:((x, y) -> x^2 + y^2 - 4); color="green", xlim=(-3, 3), ylim=(-3, 3))
```
"""
function implicit(F;
                  xlim::Tuple{Real,Real}=(-5, 5),
                  ylim::Tuple{Real,Real}=(-5, 5),
                  kwargs...)
    board = Board(""; xlim=xlim, ylim=ylim)
    ic = implicitcurve(F; kwargs...)
    push!(board, ic)
    return board
end

"""
$(SIGNATURES)

Create a board with a polar curve `r(θ)` over `θ_range`.

The polar curve is rendered as a parametric curve with
`x(θ) = r(θ)·cos(θ)` and `y(θ) = r(θ)·sin(θ)`.

# Arguments
- `r`: function or expression for the radius as a function of angle
- `θ_range`: angle range as `(θ_start, θ_end)` (default: `(0, 2π)`)
- `xlim`: x-axis range (default: auto-set to `(-rmax, rmax)` if possible)
- `ylim`: y-axis range (default: auto-set to `(-rmax, rmax)` if possible)
- Additional keyword arguments are passed to the `curve` element

# Examples
```julia
b = polar(:(θ -> 1 + cos(θ)))           # cardioid
b = polar(:(θ -> θ), (0, 4π))           # spiral
b = polar(:(θ -> 2), (0, 2π))           # circle of radius 2
```
"""
function polar(r, θ_range::Tuple{Real,Real}=(0, 2π);
               xlim::Union{Nothing,Tuple{Real,Real}}=nothing,
               ylim::Union{Nothing,Tuple{Real,Real}}=nothing,
               kwargs...)
    θ_start, θ_end = θ_range
    if θ_start == θ_end
        throw(ArgumentError("Angle range must have non-zero width, got ($θ_start, $θ_end)"))
    end

    # Convert r(θ) to parametric form: x(θ) = r(θ)*cos(θ), y(θ) = r(θ)*sin(θ)
    r_js_code = _to_jsfunction(r).code

    # Build parametric JS functions
    fx_code = "function(t){return (" * r_js_code * ")(t) * Math.cos(t);}"
    fy_code = "function(t){return (" * r_js_code * ")(t) * Math.sin(t);}"

    # Default symmetric axis limits
    if xlim === nothing
        xlim = (-5, 5)
    end
    if ylim === nothing
        ylim = (-5, 5)
    end

    board = Board(""; xlim=xlim, ylim=ylim)
    c = curve(JSFunction(fx_code), JSFunction(fy_code), θ_start, θ_end; kwargs...)
    push!(board, c)
    return board
end
