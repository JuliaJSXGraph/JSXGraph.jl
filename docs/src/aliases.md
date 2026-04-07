# Attribute Aliases

JSXGraph.jl supports Plots.jl-compatible keyword aliases for common visual attributes, allowing you to use familiar Julia plotting conventions.

## Overview

Instead of using JSXGraph-native attribute names (e.g., `strokeColor`, `strokeWidth`), you can use shorter, more intuitive aliases:

```julia
using JSXGraph

# Using aliases (recommended for most users)
p = point(1, 2; color="red", linewidth=3, fillcolor="blue")

# Equivalent JSXGraph-native attributes
p = point(1, 2; strokeColor="red", strokeWidth=3, fillColor="blue")
```

## Alias Table

| Alias | JSXGraph Attribute | Priority |
|-------|-------------------|----------|
| `color` | `strokeColor` | Full |
| `linecolor` | `strokeColor` | Full |
| `col` | `strokeColor` | Short |
| `linewidth` | `strokeWidth` | Full |
| `lw` | `strokeWidth` | Short |
| `fillcolor` | `fillColor` | Full |
| `fill` | `fillColor` | Short |
| `opacity` | `strokeOpacity`, `fillOpacity` | Full |
| `alpha` | `strokeOpacity`, `fillOpacity` | Short |
| `linestyle` | `dash` | Full |
| `ls` | `dash` | Short |
| `markersize` | `size` | Full |
| `ms` | `size` | Short |
| `label` | `name` | Full |
| `legend` | `withLabel` | Full |
| `surfacecolor` | `fillColor` | Full |
| `surfaceopacity` | `fillOpacity` | Full |
| `wireframecolor` | `strokeColor` | Full |
| `wireframewidth` | `strokeWidth` | Full |
| `meshcolor` | `meshColor` | Full |
| `meshwidth` | `meshWidth` | Full |

## Precedence Rules

When multiple names target the same JSXGraph attribute, the following precedence applies:

1. **JSXGraph-native names** always win (e.g., `strokeColor` overrides `color`)
2. **Full aliases** take precedence over short aliases (e.g., `color` overrides `col`)
3. **Unrecognized keywords** pass through unchanged to JSXGraph

```julia
# Native wins: strokeColor="blue" takes precedence over color="red"
p = point(1, 2; color="red", strokeColor="blue")
p.attributes["strokeColor"]  # "blue"

# Full alias wins: color="blue" takes precedence over col="red"
p = point(1, 2; col="red", color="blue")
p.attributes["strokeColor"]  # "blue"

# Unrecognized attributes pass through
p = point(1, 2; keepAspectRatio=true)
p.attributes["keepAspectRatio"]  # true
```

## Multi-Target Aliases

The `opacity` and `alpha` aliases expand to both `strokeOpacity` and `fillOpacity`:

```julia
p = point(1, 2; opacity=0.5)
p.attributes["strokeOpacity"]  # 0.5
p.attributes["fillOpacity"]    # 0.5
```

## Short Aliases

For rapid prototyping in notebooks, short aliases provide quick access:

```julia
p = point(1, 2; col="red", lw=3, ms=8)
# Equivalent to: point(1, 2; color="red", linewidth=3, markersize=8)
```

## Colors.jl Integration

When Colors.jl is loaded, color type objects are automatically converted to CSS color strings:

```julia
using JSXGraph
using Colors

# RGB colors → hex strings
p = point(1, 2; color=RGB(1, 0, 0))
# strokeColor becomes "#FF0000"

# RGBA colors → rgba() strings
p = point(1, 2; color=RGBA(0, 0, 1, 0.5))
# strokeColor becomes "rgba(0,0,255,0.5)"

# Named colors via colorant string macro
p = point(1, 2; fillcolor=colorant"dodgerblue")
# fillColor becomes "#1E90FF"

# HSL colors are converted to hex
p = point(1, 2; color=HSL(120, 1.0, 0.5))
# strokeColor becomes "#00FF00"
```

The conversion works with all Plots.jl-compatible aliases and across all element types.

## 3D Element Aliases

For 3D surfaces and meshes, additional aliases provide domain-specific names:

```julia
# Surface color and opacity
fg = functiongraph3d("Math.sin(x)*y"; surfacecolor="steelblue", surfaceopacity=0.5)

# Wireframe styling
ps = parametricsurface3d("cos(u)*cos(v)", "sin(u)*cos(v)", "sin(v)",
    [0, 6.28], [0, 3.14]; wireframecolor="navy", wireframewidth=2)

# Mesh grid styling
m = mesh3d([0,0,0], [1,0,0], [0,1,0], [-3,3], [-3,3];
    meshcolor="gray", meshwidth=1)
```

All existing aliases (`color`, `linewidth`, `opacity`, etc.) also work with 3D elements:

```julia
p = point3d(1, 2, 3; color="red", markersize=8)
l = line3d(point3d(0,0,0), point3d(1,1,1); linewidth=3, alpha=0.7)
```

## Works Across All Element Types

Aliases work with every element constructor:

```julia
using JSXGraph

board = Board("demo", xlim=(-5, 5), ylim=(-5, 5))

push!(board, circle(point(0, 0), 3; color="green", linewidth=2))
push!(board, functiongraph(sin; color="blue"))
push!(board, slider([0, -3], [4, -3], [1, 2, 5]; color="purple"))
```
