using Documenter
using JSXGraph

DocMeta.setdocmeta!(JSXGraph, :DocTestSetup, :(using JSXGraph); recursive=true)

makedocs(;
    modules=[JSXGraph],
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
        "HTML Generation" => "html_generation.md",
        "Display Protocol" => "display.md",
        "Geometric Elements" => "elements.md",
        "Attribute Aliases" => "aliases.md",
        "Themes" => "themes.md",
    ],
    warnonly=[:missing_docs],
)

deploydocs(; repo="github.com/s-celles/JSXGraph.jl", devbranch="main", push_preview=true)
