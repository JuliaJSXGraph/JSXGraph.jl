@testset "Attribute Aliases" begin
    # color → strokeColor
    p = point(1, 2; color="red")
    @test p.attributes["strokeColor"] == "red"
    @test !haskey(p.attributes, "color")

    # linewidth → strokeWidth
    p2 = point(1, 2; linewidth=3)
    @test p2.attributes["strokeWidth"] == 3

    # fillcolor → fillColor
    p3 = point(1, 2; fillcolor="blue")
    @test p3.attributes["fillColor"] == "blue"

    # opacity → strokeOpacity + fillOpacity
    p4 = point(1, 2; opacity=0.5)
    @test p4.attributes["strokeOpacity"] == 0.5
    @test p4.attributes["fillOpacity"] == 0.5

    # alpha → same as opacity
    p5 = point(1, 2; alpha=0.5)
    @test p5.attributes["strokeOpacity"] == 0.5
    @test p5.attributes["fillOpacity"] == 0.5

    # label → name
    p6 = point(1, 2; label="A")
    @test p6.attributes["name"] == "A"

    # legend → withLabel
    p7 = point(1, 2; legend=true)
    @test p7.attributes["withLabel"] == true

    # linestyle → dash
    p8 = point(1, 2; linestyle="dashed")
    @test p8.attributes["dash"] == "dashed"

    # markersize → size
    p9 = point(1, 2; markersize=6)
    @test p9.attributes["size"] == 6

    # linecolor → strokeColor
    p10 = point(1, 2; linecolor="green")
    @test p10.attributes["strokeColor"] == "green"
end

@testset "Alias Precedence" begin
    # Native JSXGraph name wins over alias
    p = point(1, 2; color="red", strokeColor="blue")
    @test p.attributes["strokeColor"] == "blue"

    # Passthrough: unrecognized keywords pass through
    p2 = point(1, 2; keepAspectRatio=true)
    @test p2.attributes["keepAspectRatio"] == true

    # Native JSXGraph attributes still work directly
    p3 = point(1, 2; strokeColor="red")
    @test p3.attributes["strokeColor"] == "red"
end

@testset "Aliases Across Element Types" begin
    # Geometric elements
    c = circle(point(0, 0), 3; color="green", linewidth=2)
    @test c.attributes["strokeColor"] == "green"
    @test c.attributes["strokeWidth"] == 2

    # Analytic elements
    fg = functiongraph(sin; color="blue")
    @test fg.attributes["strokeColor"] == "blue"

    # Interactive elements
    s = slider([0, -3], [4, -3], [1, 2, 5]; color="purple")
    @test s.attributes["strokeColor"] == "purple"

    # HTML output contains JSXGraph-native names
    b = Board("test_aliases")
    push!(b, point(1, 2; color="red", markersize=6))
    html = html_string(b)
    @test occursin("\"strokeColor\"", html)
    @test occursin("\"size\"", html)
end

@testset "Colors.jl Integration" begin
    using Colors

    # color_to_css for RGB
    css = JSXGraph.color_to_css(RGB(1, 0, 0))
    @test css isa String
    @test startswith(css, "#")

    # color_to_css for RGBA
    css_rgba = JSXGraph.color_to_css(RGBA(0, 0, 1, 0.5))
    @test css_rgba isa String
    @test occursin("rgba", css_rgba)

    # color_to_css for HSL
    css_hsl = JSXGraph.color_to_css(HSL(120, 1.0, 0.5))
    @test css_hsl isa String
    @test startswith(css_hsl, "#")

    # Point with RGB color → attributes contain string
    p = point(1, 2; color=RGB(1, 0, 0))
    @test p.attributes["strokeColor"] isa String

    # Point with RGBA color → attributes contain rgba string
    p2 = point(1, 2; color=RGBA(0, 0, 1, 0.5))
    @test occursin("rgba", p2.attributes["strokeColor"])

    # fillcolor with colorant
    p3 = point(1, 2; fillcolor=colorant"dodgerblue")
    @test p3.attributes["fillColor"] isa String

    # HTML output contains valid CSS, not Julia types
    b = Board("test_colors")
    push!(b, point(1, 2; color=RGB(1, 0, 0)))
    html = html_string(b)
    @test occursin("#", html)
    @test !occursin("RGB{", html)
end

@testset "Short Aliases" begin
    # col → strokeColor
    p = point(1, 2; col="green")
    @test p.attributes["strokeColor"] == "green"

    # lw → strokeWidth
    p2 = point(1, 2; lw=2)
    @test p2.attributes["strokeWidth"] == 2

    # ms → size
    p3 = point(1, 2; ms=10)
    @test p3.attributes["size"] == 10

    # ls → dash
    p4 = point(1, 2; ls="dotted")
    @test p4.attributes["dash"] == "dotted"

    # fill → fillColor
    p5 = point(1, 2; fill="yellow")
    @test p5.attributes["fillColor"] == "yellow"

    # Full alias wins over short alias
    p6 = point(1, 2; col="red", color="blue")
    @test p6.attributes["strokeColor"] == "blue"
end

@testset "3D Element Aliases" begin
    # surfacecolor → fillColor
    fg = functiongraph3d("x * y"; surfacecolor="blue")
    @test fg.attributes["fillColor"] == "blue"
    @test !haskey(fg.attributes, "surfacecolor")

    # surfaceopacity → fillOpacity
    ps = parametricsurface3d("cos(u)*cos(v)", "sin(u)*cos(v)", "sin(v)", [0, 6.28], [0, 3.14];
        surfaceopacity=0.5)
    @test ps.attributes["fillOpacity"] == 0.5

    # wireframecolor → strokeColor
    fg2 = functiongraph3d("x + y"; wireframecolor="red")
    @test fg2.attributes["strokeColor"] == "red"

    # wireframewidth → strokeWidth
    fg3 = functiongraph3d("x * y"; wireframewidth=3)
    @test fg3.attributes["strokeWidth"] == 3

    # meshcolor → meshColor
    m = mesh3d([0, 0, 0], [1, 0, 0], [0, 1, 0], [-3, 3], [-3, 3]; meshcolor="green")
    @test m.attributes["meshColor"] == "green"

    # meshwidth → meshWidth
    m2 = mesh3d([0, 0, 0], [1, 0, 0], [0, 1, 0], [-3, 3], [-3, 3]; meshwidth=2)
    @test m2.attributes["meshWidth"] == 2

    # Existing aliases still work on 3D elements
    p = point3d(1, 2, 3; color="red", markersize=8)
    @test p.attributes["strokeColor"] == "red"
    @test p.attributes["size"] == 8

    l = line3d(point3d(0, 0, 0), point3d(1, 1, 1); linewidth=3)
    @test l.attributes["strokeWidth"] == 3

    # Native JSXGraph name wins over 3D alias
    fg4 = functiongraph3d("x * y"; surfacecolor="blue", fillColor="red")
    @test fg4.attributes["fillColor"] == "red"
end
