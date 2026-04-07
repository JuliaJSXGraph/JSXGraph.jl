# Theming system for JSXGraph.jl

using TOML

"""
A theme is a nested dictionary mapping element type names to default attribute
dictionaries.

Special keys:
- `"global"`: defaults applied to all element types
- `"board"`: defaults applied to board constructor options
"""
const Theme = Dict{String,Dict{String,Any}}

# --- Built-in themes ---

"""
Default theme — empty, preserving JSXGraph native defaults.
"""
const THEME_DEFAULT = Theme()

"""
Dark theme with light-colored elements on a dark background.
"""
const THEME_DARK = Theme(
    "board" => Dict{String,Any}("background" => "#2d2d2d"),
    "global" => Dict{String,Any}("strokeColor" => "#e0e0e0"),
    "point" => Dict{String,Any}("strokeColor" => "#ff6b6b", "fillColor" => "#ff6b6b"),
    "line" => Dict{String,Any}("strokeColor" => "#4ecdc4", "strokeWidth" => 2),
    "segment" => Dict{String,Any}("strokeColor" => "#4ecdc4"),
    "arrow" => Dict{String,Any}("strokeColor" => "#4ecdc4"),
    "circle" => Dict{String,Any}(
        "strokeColor" => "#45b7d1", "fillColor" => "#45b7d1", "fillOpacity" => 0.1
    ),
    "functiongraph" => Dict{String,Any}("strokeColor" => "#ffd93d", "strokeWidth" => 2),
    "curve" => Dict{String,Any}("strokeColor" => "#ffd93d", "strokeWidth" => 2),
    "polygon" => Dict{String,Any}(
        "strokeColor" => "#4ecdc4", "fillColor" => "#4ecdc4", "fillOpacity" => 0.15
    ),
    "text" => Dict{String,Any}("cssStyle" => "color: #e0e0e0"),
    "slider" => Dict{String,Any}("strokeColor" => "#4ecdc4", "fillColor" => "#45b7d1"),
    "axis" => Dict{String,Any}("strokeColor" => "#888888"),
    "grid" => Dict{String,Any}("strokeColor" => "#444444"),
    # 3D elements
    "point3d" => Dict{String,Any}("strokeColor" => "#ff6b6b", "fillColor" => "#ff6b6b"),
    "line3d" => Dict{String,Any}("strokeColor" => "#4ecdc4", "strokeWidth" => 2),
    "curve3d" => Dict{String,Any}("strokeColor" => "#ffd93d", "strokeWidth" => 2),
    "functiongraph3d" => Dict{String,Any}(
        "strokeColor" => "#ffd93d", "fillColor" => "#45b7d1", "fillOpacity" => 0.6
    ),
    "parametricsurface3d" => Dict{String,Any}(
        "strokeColor" => "#ffd93d", "fillColor" => "#45b7d1", "fillOpacity" => 0.6
    ),
    "sphere3d" => Dict{String,Any}(
        "strokeColor" => "#45b7d1", "fillColor" => "#45b7d1", "fillOpacity" => 0.3
    ),
    "circle3d" => Dict{String,Any}("strokeColor" => "#45b7d1", "strokeWidth" => 2),
    "polygon3d" => Dict{String,Any}(
        "strokeColor" => "#4ecdc4", "fillColor" => "#4ecdc4", "fillOpacity" => 0.15
    ),
    "plane3d" => Dict{String,Any}(
        "strokeColor" => "#4ecdc4", "fillColor" => "#4ecdc4", "fillOpacity" => 0.1
    ),
    "text3d" => Dict{String,Any}("cssStyle" => "color: #e0e0e0"),
    "vectorfield3d" => Dict{String,Any}("strokeColor" => "#ff6b6b"),
    "mesh3d" => Dict{String,Any}("strokeColor" => "#888888"),
    "polyhedron3d" => Dict{String,Any}("fillColor" => "#45b7d1", "fillOpacity" => 0.4),
)

"""
Publication-quality theme: black/white with clean lines for academic papers.
"""
const THEME_PUBLICATION = Theme(
    "board" => Dict{String,Any}("background" => "#ffffff"),
    "global" => Dict{String,Any}("strokeColor" => "#000000", "strokeWidth" => 1.5),
    "point" => Dict{String,Any}(
        "strokeColor" => "#000000", "fillColor" => "#000000", "size" => 2
    ),
    "line" => Dict{String,Any}("strokeColor" => "#000000", "strokeWidth" => 1.5),
    "segment" => Dict{String,Any}("strokeColor" => "#000000"),
    "arrow" => Dict{String,Any}("strokeColor" => "#000000"),
    "circle" => Dict{String,Any}(
        "strokeColor" => "#000000", "fillColor" => "none", "fillOpacity" => 0
    ),
    "functiongraph" => Dict{String,Any}("strokeColor" => "#000000", "strokeWidth" => 2),
    "curve" => Dict{String,Any}("strokeColor" => "#000000", "strokeWidth" => 2),
    "polygon" => Dict{String,Any}(
        "strokeColor" => "#000000", "fillColor" => "none", "fillOpacity" => 0
    ),
    "text" => Dict{String,Any}("cssStyle" => "font-family: serif"),
    "axis" => Dict{String,Any}("strokeColor" => "#000000"),
    "grid" => Dict{String,Any}("strokeColor" => "#cccccc", "strokeOpacity" => 0.5),
    # 3D elements
    "point3d" => Dict{String,Any}(
        "strokeColor" => "#000000", "fillColor" => "#000000", "size" => 2
    ),
    "line3d" => Dict{String,Any}("strokeColor" => "#000000", "strokeWidth" => 1.5),
    "curve3d" => Dict{String,Any}("strokeColor" => "#000000", "strokeWidth" => 2),
    "functiongraph3d" => Dict{String,Any}(
        "strokeColor" => "#333333", "fillColor" => "#cccccc", "fillOpacity" => 0.4
    ),
    "parametricsurface3d" => Dict{String,Any}(
        "strokeColor" => "#333333", "fillColor" => "#cccccc", "fillOpacity" => 0.4
    ),
    "sphere3d" => Dict{String,Any}(
        "strokeColor" => "#000000", "fillColor" => "none", "fillOpacity" => 0
    ),
    "circle3d" => Dict{String,Any}("strokeColor" => "#000000", "strokeWidth" => 1.5),
    "polygon3d" => Dict{String,Any}(
        "strokeColor" => "#000000", "fillColor" => "none", "fillOpacity" => 0
    ),
    "plane3d" => Dict{String,Any}(
        "strokeColor" => "#000000", "fillColor" => "none", "fillOpacity" => 0
    ),
    "text3d" => Dict{String,Any}("cssStyle" => "font-family: serif"),
    "vectorfield3d" => Dict{String,Any}("strokeColor" => "#000000"),
    "mesh3d" => Dict{String,Any}("strokeColor" => "#666666"),
    "polyhedron3d" => Dict{String,Any}("fillColor" => "#cccccc", "fillOpacity" => 0.3),
)

"""
Named theme registry mapping symbols to theme dictionaries.
"""
const THEME_REGISTRY = Dict{Symbol,Theme}(
    :default => THEME_DEFAULT, :dark => THEME_DARK, :publication => THEME_PUBLICATION
)

"""
Global current theme reference.
"""
const _CURRENT_THEME = Ref{Theme}(Theme())

# --- Public API ---

"""
$(SIGNATURES)

Return the currently active theme. Task-local themes (set via [`with_theme`](@ref))
take precedence over the global theme (set via [`set_theme!`](@ref)).
"""
function current_theme()::Theme
    return get(task_local_storage(), :jsxgraph_theme, _CURRENT_THEME[])::Theme
end

"""
$(SIGNATURES)

Set the global theme. Accepts a [`Theme`](@ref) dictionary or a built-in theme
name (`:default`, `:dark`, `:publication`).

# Examples
```julia
set_theme!(:dark)
set_theme!(THEME_PUBLICATION)
```
"""
function set_theme!(theme::Theme)
    _CURRENT_THEME[] = theme
    return theme
end

function set_theme!(name::Symbol)
    if !haskey(THEME_REGISTRY, name)
        valid = join(sort(collect(string.(keys(THEME_REGISTRY)))), ", :")
        throw(ArgumentError("Unknown theme :$name. Available themes: :$valid"))
    end
    return set_theme!(THEME_REGISTRY[name])
end

"""
$(SIGNATURES)

Reset the global theme to the default (empty) theme.
"""
function reset_theme!()
    return set_theme!(THEME_DEFAULT)
end

"""
$(SIGNATURES)

Execute `f()` with a temporary theme active. The previous theme is restored
after `f` returns, even if `f` throws an error.

# Examples
```julia
with_theme(:dark) do
    b = Board("myboard")
    p = point(1, 2)  # gets dark theme defaults
    push!(b, p)
end
```
"""
function with_theme(f, theme::Theme)
    task_local_storage(:jsxgraph_theme, theme) do
        f()
    end
end

function with_theme(f, name::Symbol)
    if !haskey(THEME_REGISTRY, name)
        valid = join(sort(collect(string.(keys(THEME_REGISTRY)))), ", :")
        throw(ArgumentError("Unknown theme :$name. Available themes: :$valid"))
    end
    return with_theme(f, THEME_REGISTRY[name])
end

"""
$(SIGNATURES)

Register a custom theme in the global theme registry for later use with
`set_theme!(:name)` or `with_theme(:name)`.

# Examples
```julia
my_theme = Theme(
    "point" => Dict{String,Any}("strokeColor" => "purple"),
)
register_theme!(:my_style, my_theme)
set_theme!(:my_style)
```
"""
function register_theme!(name::Symbol, theme::Theme)
    THEME_REGISTRY[name] = theme
    return theme
end

"""
$(SIGNATURES)

Load a theme from a TOML or JSON file. Dispatches on file extension.

# TOML format
```toml
[global]
strokeColor = "#000000"

[point]
size = 3
fillColor = "#ff0000"

[board]
background = "#ffffff"
```

# JSON format
```json
{
    "global": {"strokeColor": "#000000"},
    "point": {"size": 3, "fillColor": "#ff0000"},
    "board": {"background": "#ffffff"}
}
```
"""
function load_theme(filename::String)::Theme
    ext = lowercase(splitext(filename)[2])
    if ext == ".toml"
        return _load_theme_toml(filename)
    elseif ext == ".json"
        return _load_theme_json(filename)
    else
        throw(ArgumentError("Unsupported theme file format: '$ext'. Use .toml or .json"))
    end
end

function _load_theme_toml(filename::String)::Theme
    raw = TOML.parsefile(filename)
    return _normalize_theme(raw)
end

function _load_theme_json(filename::String)::Theme
    raw = JSON.parsefile(filename)
    return _normalize_theme(raw)
end

"""
$(SIGNATURES)

Normalize a raw parsed dictionary into a Theme.
Ensures all inner values are Dict{String, Any}.
"""
function _normalize_theme(raw::Dict)::Theme
    theme = Theme()
    for (section, attrs) in raw
        if attrs isa Dict
            theme[string(section)] = Dict{String,Any}(string(k) => v for (k, v) in attrs)
        end
    end
    return theme
end

# --- Internal helpers ---

"""
$(SIGNATURES)

Merge theme defaults under user-provided attributes.

Priority (highest to lowest):
1. User-provided attributes (from kwargs + alias resolution)
2. Element-specific theme defaults
3. Global theme defaults
"""
function apply_theme_defaults(type_name::String, user_attrs::Dict{String,Any})
    theme = current_theme()
    isempty(theme) && return user_attrs

    merged = Dict{String,Any}()

    # Global defaults (lowest priority)
    if haskey(theme, "global")
        merge!(merged, theme["global"])
    end

    # Element-specific defaults
    if haskey(theme, type_name)
        merge!(merged, theme[type_name])
    end

    # User attributes override everything
    merge!(merged, user_attrs)

    return merged
end

"""
$(SIGNATURES)

Return board-level theme defaults from the current theme's `"board"` key.
"""
function board_theme_defaults()::Dict{String,Any}
    theme = current_theme()
    if haskey(theme, "board")
        return copy(theme["board"])
    end
    return Dict{String,Any}()
end
