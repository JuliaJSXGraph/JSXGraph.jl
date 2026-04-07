using Test
using JSXGraph
using JSXGraphRecipesBase
using Colors
using Tables
using Observables
using NodeJS_22_jll
using HTTP

@testset "JSXGraph.jl" begin
    include("test_types.jl")
    include("test_options.jl")
    include("test_html.jl")
    include("test_display.jl")
    include("test_elements.jl")
    include("test_elements3d.jl")
    include("test_composition.jl")
    include("test_jsfunction.jl")
    include("test_mathjs.jl")
    include("test_aliases.jl")
    include("test_themes.jl")
    include("test_tables.jl")
    include("test_unitful.jl")
    include("test_observables.jl")
    include("test_recipes.jl")
    include("test_snapshots.jl")
    include("test_svg_export.jl")
    include("test_websocket.jl")
end

