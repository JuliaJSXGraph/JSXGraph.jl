# Themes

JSXGraph.jl includes a flexible theming system that lets you set default visual attributes for all element types. Use themes to quickly switch between visual styles — such as dark mode for presentations or black-and-white for publications.

## Built-in Themes

Three themes ship out of the box:

| Theme | Symbol | Description |
|---|---|---|
| `THEME_DEFAULT` | `:default` | Empty — preserves JSXGraph native defaults |
| `THEME_DARK` | `:dark` | Light-colored elements on a dark background |
| `THEME_PUBLICATION` | `:publication` | Black/white with clean lines for academic papers |

## Usage

### Setting the Global Theme

```julia
using JSXGraph

# Set by symbol
set_theme!(:dark)

# Set by Theme object
set_theme!(THEME_PUBLICATION)

# Reset to default (no theme)
reset_theme!()
```

### Scoped Themes with `with_theme`

Use `with_theme` for temporary theme changes that automatically restore the previous theme:

```julia
with_theme(:dark) do
    b = Board("myboard")
    p = point(1, 2)     # inherits dark theme colors
    l = line(p, point(3, 4))
    push!(b, p, l)
end
# theme is restored here
```

### User Attributes Override Theme

Theme defaults have the **lowest priority**. User-provided keyword arguments always win:

```julia
set_theme!(:dark)

# Dark theme sets point strokeColor to "#ff6b6b"
# but the user kwarg overrides it:
p = point(1, 2; color="green")
# p.attributes["strokeColor"] == "green"
```

Priority order (highest to lowest):
1. JSXGraph-native keyword arguments (e.g., `strokeColor="red"`)
2. Full alias keywords (e.g., `color="red"`)
3. Short alias keywords (e.g. `col="red"`)
4. Element-specific theme defaults
5. Global theme defaults

## Board Theming

Themes can include a `"board"` key with defaults for board options (e.g., background color):

```julia
set_theme!(:dark)
b = Board("myboard")  # automatically gets background="#2d2d2d"
```

Explicit board options always override theme defaults:

```julia
set_theme!(:dark)
b = Board("myboard"; background="#ffffff")  # overrides dark background
```

## Custom Themes

### Creating a Theme

A `Theme` is a `Dict{String, Dict{String, Any}}` mapping element type names to default attributes:

```julia
my_theme = Theme(
    "global" => Dict{String,Any}("strokeColor" => "#333333"),
    "point"  => Dict{String,Any}("size" => 5, "fillColor" => "orange"),
    "line"   => Dict{String,Any}("strokeWidth" => 3),
    "board"  => Dict{String,Any}("background" => "#f0f0f0"),
)

set_theme!(my_theme)
```

Special keys:
- `"global"` — defaults applied to **all** element types
- `"board"` — defaults applied to board constructor options

### Registering Custom Themes

Register a theme for later use by symbol name:

```julia
register_theme!(:my_style, my_theme)

# Now you can use it by name:
set_theme!(:my_style)
with_theme(:my_style) do
    # ...
end
```

## Loading Themes from Files

Load themes from TOML or JSON files:

### TOML format

```toml
# my_theme.toml
[global]
strokeColor = "#000000"
strokeWidth = 1.5

[point]
size = 3
fillColor = "#ff0000"

[board]
background = "#ffffff"
```

```julia
theme = load_theme("my_theme.toml")
set_theme!(theme)
```

### JSON format

```json
{
    "global": {"strokeColor": "#000000", "strokeWidth": 1.5},
    "point": {"size": 3, "fillColor": "#ff0000"},
    "board": {"background": "#ffffff"}
}
```

```julia
theme = load_theme("my_theme.json")
set_theme!(theme)
```

## 3D Element Theming

The built-in themes include defaults for all 3D element types. When using `THEME_DARK` or `THEME_PUBLICATION`, 3D elements automatically pick up consistent styling:

```julia
using JSXGraph

set_theme!(:dark)

b = board() do
    v = view3d([-4, -3], [8, 8], xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5))
    View3D(v) do
        push!(v, point3d(1, 2, 3))                  # dark point colors
        push!(v, functiongraph3d("Math.sin(x)*y"))   # dark surface colors
        push!(v, sphere3d(point3d(0, 0, 0), 2.0))    # semi-transparent
    end
    push!(b, v)
end
```

### 3D Element Theme Keys

| Element Type | Dark Theme | Publication Theme |
|---|---|---|
| `point3d` | Red points (`#ff6b6b`) | Black points |
| `line3d` | Teal (`#4ecdc4`) | Black |
| `curve3d` | Gold (`#ffd93d`) | Black |
| `functiongraph3d` | Gold wireframe + blue fill | Gray wireframe + light fill |
| `parametricsurface3d` | Gold wireframe + blue fill | Gray wireframe + light fill |
| `sphere3d` | Blue, semi-transparent | Black outline, no fill |
| `circle3d` | Blue (`#45b7d1`) | Black |
| `polygon3d` | Teal, semi-transparent | Black outline, no fill |
| `plane3d` | Teal, semi-transparent | Black outline, no fill |
| `text3d` | Light text | Serif font |
| `vectorfield3d` | Red (`#ff6b6b`) | Black |
| `mesh3d` | Gray wireframe | Dark gray wireframe |
| `polyhedron3d` | Blue faces | Light gray faces |

Custom themes can include any 3D element type name as a key:

```julia
my_3d_theme = Theme(
    "functiongraph3d" => Dict{String,Any}(
        "fillColor" => "steelblue", "fillOpacity" => 0.5,
        "strokeColor" => "navy"
    ),
    "point3d" => Dict{String,Any}("size" => 4, "fillColor" => "orange"),
)
register_theme!(:my_3d, my_3d_theme)
```

## API Reference

```@docs
set_theme!
reset_theme!
with_theme
current_theme
load_theme
register_theme!
```
