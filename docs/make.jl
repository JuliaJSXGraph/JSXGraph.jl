using Documenter
using JSXGraph
using JSXGraphRecipesBase

DocMeta.setdocmeta!(JSXGraph, :DocTestSetup, :(using JSXGraph); recursive=true)

# Optionally render the Pluto notebook for the Pluto Integration page.
# Gated on BUILD_PLUTO_NOTEBOOKS=true to keep the default doc build fast
# and immune to Pluto/PlutoStaticHTML resolver surprises.
if get(ENV, "BUILD_PLUTO_NOTEBOOKS", "false") == "true"
    try
        @info "Rendering Pluto notebooks via PlutoStaticHTML…"
        @eval using PlutoStaticHTML
        notebook_dir = joinpath(@__DIR__, "notebooks")
        opts = PlutoStaticHTML.BuildOptions(
            notebook_dir; output_format=PlutoStaticHTML.html_output
        )
        PlutoStaticHTML.build_notebooks(opts)
        # Splice the rendered HTML into pluto_bind.md between the marker
        # comments. Cache file lives next to the notebook (.html sibling).
        nb_html_path = joinpath(notebook_dir, "pluto_bind_demo.html")
        if isfile(nb_html_path)
            rendered = read(nb_html_path, String)
            md_path = joinpath(@__DIR__, "src", "pluto_bind.md")
            md = read(md_path, String)
            md = replace(
                md,
                r"<!-- PLUTO_NOTEBOOK_START -->.*?<!-- PLUTO_NOTEBOOK_END -->"s =>
                    "<!-- PLUTO_NOTEBOOK_START -->\n```@raw html\n" *
                    rendered *
                    "\n```\n<!-- PLUTO_NOTEBOOK_END -->",
            )
            write(md_path, md)
            @info "Pluto notebook embedded into pluto_bind.md"
        else
            @warn "Expected rendered notebook at $nb_html_path; page will keep its fallback content."
        end
    catch e
        @warn "Pluto notebook render skipped (set BUILD_PLUTO_NOTEBOOKS=true and ensure PlutoStaticHTML resolves)" exception=(
            e, catch_backtrace()
        )
    end
end

makedocs(;
    modules=[JSXGraph, JSXGraphRecipesBase],
    authors="Sebastien Celles <s.celles@gmail.com> and contributors",
    sitename="JSXGraph.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaJSXGraph.github.io/JSXGraph.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "tutorial.md",
        "Gallery" => "gallery.md",
        "3D Gallery" => "gallery3d.md",
        "Wiki Examples" => "wiki_examples.md",
        "HTML Generation" => "html_generation.md",
        "Static Export" => "svg_export.md",
        "Display Protocol" => "display.md",
        "Geometric Elements" => "elements.md",
        "Attribute Aliases" => "aliases.md",
        "Themes" => "themes.md",
        "MathJS Integration" => "mathjs.md",
        "Recipe System" => "recipes.md",
        "Observables.jl" => "observables.md",
        "Pluto Integration" => "pluto_bind.md",
        "API Reference" => "api.md",
    ],
    warnonly=[:missing_docs, :docs_block],
)

deploydocs(;
    repo="github.com/JuliaJSXGraph/JSXGraph.jl", devbranch="main", push_preview=true
)
