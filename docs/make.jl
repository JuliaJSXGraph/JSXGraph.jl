using Documenter
using JSXGraph
using JSXGraphRecipesBase

DocMeta.setdocmeta!(JSXGraph, :DocTestSetup, :(using JSXGraph); recursive=true)

makedocs(;
    modules=[JSXGraph, JSXGraphRecipesBase],
    authors="Sebastien Celles <s.celles@gmail.com> and contributors",
    sitename="JSXGraph.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://s-celles.github.io/JSXGraph.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "tutorial.md",
        "HTML Generation" => "html_generation.md",
        "Static Export" => "svg_export.md",
        "Display Protocol" => "display.md",
        "Geometric Elements" => "elements.md",
        "Attribute Aliases" => "aliases.md",
        "Themes" => "themes.md",
        "Recipe System" => "recipes.md",
    ],
    warnonly=[:missing_docs, :docs_block],
)

deploydocs(; repo="github.com/s-celles/JSXGraph.jl", devbranch="main", push_preview=true)
