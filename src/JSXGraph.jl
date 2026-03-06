module JSXGraph

using DocStringExtensions
using JSON
using Artifacts
using Random: randstring
using JSXGraphRecipesBase

export AbstractJSXElement, Board
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

# Composition and transformation elements
export group, transformation, reflection, rotation, translation
export grid, axis, ticks, legend

# Composition and convenience
export board, plot, plot!, scatter, parametric, implicit, polar
export julia_to_js, @jsf, @named_jsf, named_jsf, with_deps

# Theming
export Theme, THEME_DEFAULT, THEME_DARK, THEME_PUBLICATION
export set_theme!, reset_theme!, with_theme, current_theme
export load_theme, register_theme!

# Recipe system (re-exported from JSXGraphRecipesBase)
export ElementSpec, @jsxrecipe, apply_recipe, has_recipe
export realize_specs

"""
    sorted_json(d::AbstractDict) -> String

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
        v = d[k]
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

end # module JSXGraph
