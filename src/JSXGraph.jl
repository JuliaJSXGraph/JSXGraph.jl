module JSXGraph

using DocStringExtensions
using JSON
using Artifacts
using Random: randstring

export AbstractJSXElement, Board
export JSXElement, JSFunction
export JSXGRAPH_VERSION
export html_string, html_page, html_fragment, save
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
export board, plot, scatter, parametric, implicit, polar
export julia_to_js, @jsf

# Theming
export Theme, THEME_DEFAULT, THEME_DARK, THEME_PUBLICATION
export set_theme!, reset_theme!, with_theme, current_theme
export load_theme, register_theme!

include("themes.jl")
include("types.jl")
include("aliases.jl")
include("elements.jl")
include("jsfunction.jl")
include("composition.jl")
include("assets.jl")
include("options.jl")
include("html.jl")
include("display.jl")

end # module JSXGraph
