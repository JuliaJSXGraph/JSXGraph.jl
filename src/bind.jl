# Pluto `@bind` integration for JSXGraph boards.
#
# Public surface (added incrementally across T011–T028):
#   - `bindable=true` keyword on `Board(...)` (T011, T013)
#   - `points_xy(state)`  (T014)
#   - `points_xyz(state)` (T026)
#
# Internal helpers used by the HTML renderer and validation:
#   - `_interactive_elements(board)`
#   - `_bind_key(elem, counters)`
#   - `_kind_of(elem)` / `_is_bindable_kind(elem)`
#   - `_validate_bindable_names!(board)`

"""
Reference to one interactive element on a bindable board: the bound-state
key, the element kind (`:point`, `:point3d`, `:slider`), and the element
itself.
"""
struct _InteractiveRef
    name::String
    kind::Symbol
    elem::AbstractJSXElement
end

_is_bindable_kind(elem::AbstractJSXElement) = false
function _is_bindable_kind(elem::JSXElement)
    tn = elem.type_name
    if tn == "point" || tn == "point3d"
        return get(elem.attributes, "fixed", false) === false
    end
    return tn == "slider"
end

_kind_of(elem::AbstractJSXElement) = :other
function _kind_of(elem::JSXElement)
    elem.type_name == "point" && return :point
    elem.type_name == "point3d" && return :point3d
    elem.type_name == "slider" && return :slider
    return :other
end

"""
Derive the bound-state key for an interactive element. Returns the
user-supplied `name` attribute if non-empty; otherwise `"\$(kind)_\$i"`
with a per-kind counter incremented on each call.
"""
function _bind_key(elem::JSXElement, counters::Dict{Symbol,Int})
    kind = _kind_of(elem)
    nm = get(elem.attributes, "name", nothing)
    if nm isa AbstractString && !isempty(nm)
        return String(nm)
    end
    counters[kind] = get(counters, kind, 0) + 1
    return string(kind) * "_" * string(counters[kind])
end

"""
Return the interactive elements of `board` in stable declaration order.
Each entry carries its bound-state key, its kind, and the element itself.
`View3D` containers are walked one level deep so `point3d` children are
discovered.
"""
function _interactive_elements(board::Board)::Vector{_InteractiveRef}
    refs = _InteractiveRef[]
    counters = Dict{Symbol,Int}()
    for elem in board.elements
        if elem isa View3D
            for child in elem.elements
                if child isa JSXElement && _is_bindable_kind(child)
                    push!(
                        refs,
                        _InteractiveRef(_bind_key(child, counters), _kind_of(child), child),
                    )
                end
            end
        elseif elem isa JSXElement && _is_bindable_kind(elem)
            push!(refs, _InteractiveRef(_bind_key(elem, counters), _kind_of(elem), elem))
        end
    end
    return refs
end

"""
Construct the seed bound-state dict for a bindable board by reading
each interactive element's construction-time values. Mirrors what the
JS-side `snapshot()` emits on its initial publish, so Pluto's
`Bonds.initial_value(::Board)` can deliver a meaningful first-run
value before the browser has dispatched any `input` event.
"""
function _initial_bound_state(board::Board)::Dict{String,Any}
    state = Dict{String,Any}()
    for r in _interactive_elements(board)
        p = r.elem.parents
        if r.kind === :point && length(p) >= 2
            state[r.name] = (x=Float64(p[1]), y=Float64(p[2]))
        elseif r.kind === :point3d && length(p) >= 3
            state[r.name] = (x=Float64(p[1]), y=Float64(p[2]), z=Float64(p[3]))
        elseif r.kind === :slider &&
            length(p) >= 3 &&
            p[3] isa AbstractVector &&
            length(p[3]) >= 2
            state[r.name] = Float64(p[3][2])
        end
    end
    return state
end

"""
Validate that no two interactive elements on a bindable board share a key.
Raises `ArgumentError` on the first duplicate found. No-op when the board
is not bindable.
"""
function _validate_bindable_names!(board::Board)
    get(board.options, "bindable", false) === true || return nothing
    seen = Dict{String,Symbol}()
    for r in _interactive_elements(board)
        if haskey(seen, r.name)
            prev = seen[r.name]
            kinds = if prev == r.kind
                "two $(r.kind) elements"
            else
                "elements of kind $(prev) and $(r.kind)"
            end
            throw(
                ArgumentError(
                    string(
                        "Bindable board \"",
                        board.id,
                        "\" has duplicate element name \"",
                        r.name,
                        "\" used by ",
                        kinds,
                        ". Rename one of them, or set bindable=false.",
                    ),
                ),
            )
        end
        seen[r.name] = r.kind
    end
    return nothing
end

# ---------------------------------------------------------------------
# Public helpers (T014, T026)
# ---------------------------------------------------------------------

"""
    points_xy(state) -> (xs::Vector{Float64}, ys::Vector{Float64})

Project the bound state of a bindable board into parallel `x` and `y`
coordinate vectors, in the declaration order of the 2D points on the
board. 3D points and sliders are skipped.

State entries are recognised as 2D points when they look like a 2-tuple
`(x, y)` or a 2-key dict / NamedTuple `(x = …, y = …)`.

Companion to [`points_xyz`](@ref).
"""
function points_xy(state::AbstractDict)
    xs = Float64[]
    ys = Float64[]
    order = get(state, "_order", nothing)
    keys_iter = order isa AbstractVector ? order : keys(state)
    for k in keys_iter
        k == "_order" && continue
        haskey(state, k) || continue
        v = state[k]
        if _looks_like_xy(v)
            push!(xs, Float64(_get_field(v, :x, "x")))
            push!(ys, Float64(_get_field(v, :y, "y")))
        end
    end
    return xs, ys
end

# Tolerate the first-run case in Pluto where `@bind state ...` may
# return `nothing` or `missing` before the browser dispatches the
# initial `input` event. Returning empty vectors lets downstream cells
# render harmlessly until the real state arrives.
points_xy(::Nothing) = (Float64[], Float64[])
points_xy(::Missing) = (Float64[], Float64[])

"""
    points_xyz(state) -> (xs::Vector{Float64}, ys::Vector{Float64}, zs::Vector{Float64})

Project the bound state into parallel `x`, `y`, `z` coordinate vectors,
in declaration order of the 3D points on the board. 2D points and
sliders are skipped.
"""
function points_xyz(state::AbstractDict)
    xs = Float64[]
    ys = Float64[]
    zs = Float64[]
    order = get(state, "_order", nothing)
    keys_iter = order isa AbstractVector ? order : keys(state)
    for k in keys_iter
        k == "_order" && continue
        haskey(state, k) || continue
        v = state[k]
        if _looks_like_xyz(v)
            push!(xs, Float64(_get_field(v, :x, "x")))
            push!(ys, Float64(_get_field(v, :y, "y")))
            push!(zs, Float64(_get_field(v, :z, "z")))
        end
    end
    return xs, ys, zs
end

points_xyz(::Nothing) = (Float64[], Float64[], Float64[])
points_xyz(::Missing) = (Float64[], Float64[], Float64[])

# Predicates: support NamedTuple-shaped (Julia native) and Dict-shaped
# (post-JSON-decode) values without coupling to a specific decoder.
_has_field(v::NamedTuple, sym::Symbol) = sym in fieldnames(typeof(v))
_has_field(v::AbstractDict, sym::Symbol) = haskey(v, string(sym)) || haskey(v, sym)
_has_field(::Any, ::Symbol) = false

function _looks_like_xy(v)
    _has_field(v, :x) && _has_field(v, :y) && !_has_field(v, :z)
end

function _looks_like_xyz(v)
    _has_field(v, :x) && _has_field(v, :y) && _has_field(v, :z)
end

_get_field(v::NamedTuple, sym::Symbol, ::String) = getfield(v, sym)
function _get_field(v::AbstractDict, sym::Symbol, str::String)
    haskey(v, str) ? v[str] : v[sym]
end
