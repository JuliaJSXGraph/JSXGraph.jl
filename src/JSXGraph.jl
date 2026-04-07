module JSXGraph

using DocStringExtensions
using JSON
using Artifacts
using Random: randstring
using JSXGraphRecipesBase

export AbstractJSXElement, Board, View3D
export JSXElement, JSFunction
export JSXGRAPH_VERSION
export html_string, html_page, html_fragment, save, save_svg, save_png, save_pdf
export open_in_browser

# Element constructors
export point, line, segment, arrow, circle, arc, sector
export polygon, regularpolygon, angle, conic, ellipse, parabola, hyperbola
export functiongraph, curve, implicitcurve, inequality
export tangent, normal, integral, derivative, riemannsum, slopefield, vectorfield
export slider, checkbox, input, button, glider, tapemeasure, text, image

# 3D Element constructors
export view3d, point3d, line3d, curve3d, functiongraph3d, parametricsurface3d, vectorfield3d
export sphere3d, circle3d, polygon3d, plane3d
export intersectionline3d, intersectioncircle3d, text3d, mesh3d, polyhedron3d

# Composition and transformation elements
export group, transformation, reflection, rotation, translation
export grid, axis, ticks, legend

# Composition and convenience
export board, plot, plot!, scatter, parametric, implicit, polar
export julia_to_js, @jsf, @named_jsf, named_jsf, with_deps
export enable_mathjs!, disable_mathjs!, mathjs_enabled
export MATHJS_VERSION, MATHJS_CDN_JS

# WebSocket interactivity
export LiveBoard, serve, stop_server!, on, off, update!

# Theming
export Theme, THEME_DEFAULT, THEME_DARK, THEME_PUBLICATION
export set_theme!, reset_theme!, with_theme, current_theme
export load_theme, register_theme!

# Recipe system (re-exported from JSXGraphRecipesBase)
export ElementSpec, @jsxrecipe, apply_recipe, has_recipe
export realize_specs

"""
$(SIGNATURES)

Unwrap a value for rendering. Returns the value unchanged by default.

Package extensions (e.g. JSXGraphObservablesExt) can add methods to unwrap
wrapper types such as `Observable` before HTML/JS generation.
"""
resolve_value(x) = x

"""
$(SIGNATURES)

Serialize a dictionary to JSON with keys sorted alphabetically.
Ensures deterministic output across Julia versions and platforms.
"""
function sorted_json(d::AbstractDict)
    io = IOBuffer()
    write(io, "{")
    for (i, k) in enumerate(sort(collect(keys(d))))
        i > 1 && write(io, ",")
        JSON.print(io, k)
        write(io, ":")
        v = resolve_value(d[k])
        if v isa AbstractDict
            write(io, sorted_json(v))
        else
            JSON.print(io, v)
        end
    end
    write(io, "}")
    return String(take!(io))
end

include("themes.jl")
include("types.jl")
include("aliases.jl")
include("elements.jl")
include("jsfunction.jl")
include("composition.jl")
include("assets.jl")
include("options.jl")
include("html.jl")
include("svg_export.jl")
include("display.jl")
include("recipes.jl")
include("websocket.jl")

end # module JSXGraph
