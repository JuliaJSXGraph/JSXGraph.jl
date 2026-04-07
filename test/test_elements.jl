@testset "Geometric Primitives" begin
    # Point
    p = point(2, 3)
    @test p isa JSXElement
    @test p.type_name == "point"
    @test p.parents == Any[2, 3]

    # Point with attributes
    p2 = point(2, 3; color="red", size=4)
    @test p2.attributes["strokeColor"] == "red"
    @test p2.attributes["size"] == 4

    # Line with element references
    p1 = point(-1, 0)
    p3 = point(1, 0)
    l = line(p1, p3)
    @test l.type_name == "line"
    @test l.parents[1] === p1
    @test l.parents[2] === p3

    # Circle
    c = circle(p1, 3)
    @test c.type_name == "circle"
    @test c.parents[1] === p1
    @test c.parents[2] == 3

    # All 14 geometric primitives return correct type_name
    @test segment(p1, p3).type_name == "segment"
    @test arrow(p1, p3).type_name == "arrow"
    @test arc(p1, p3, point(0, 1)).type_name == "arc"
    @test sector(p1, p3, point(0, 1)).type_name == "sector"
    @test polygon(p1, p3, point(0, 1)).type_name == "polygon"
    @test regularpolygon(p1, p3, 5).type_name == "regularpolygon"
    @test JSXGraph.angle(p1, point(0, 0), p3).type_name == "angle"
    @test conic(p1, p3, point(0, 1), point(1, 1), point(-1, 1)).type_name == "conic"
    @test ellipse(p1, p3, point(0, 2)).type_name == "ellipse"
    @test parabola(p1, l).type_name == "parabola"
    @test hyperbola(p1, p3, point(0, 2)).type_name == "hyperbola"
end

@testset "Analytic Elements" begin
    # functiongraph with Julia function
    fg = functiongraph(sin)
    @test fg isa JSXElement
    @test fg.type_name == "functiongraph"
    @test length(fg.parents) == 1
    @test fg.parents[1] isa JSFunction

    # functiongraph with expression
    fg2 = functiongraph(:(x -> x^2))
    @test fg2.type_name == "functiongraph"
    @test fg2.parents[1] isa JSFunction

    # curve
    c = curve(cos, sin, 0, 2π)
    @test c isa JSXElement
    @test c.type_name == "curve"

    # derivative references another element
    d = derivative(fg)
    @test d.type_name == "derivative"
    @test d.parents[1] === fg

    # HTML output contains JS function
    b = Board("test_fg")
    push!(b, fg)
    html = html_string(b)
    @test occursin("create('functiongraph'", html)
    @test occursin("Math.sin", html)

    # All 11 analytic constructors
    p1 = point(0, 0)
    l = line(p1, point(1, 0))
    gl = glider(0, 0, fg)
    @test implicitcurve(:(x -> x^2 + 1)).type_name == "implicitcurve"
    @test inequality(l).type_name == "inequality"
    @test tangent(gl).type_name == "tangent"
    @test normal(gl).type_name == "normal"
    @test integral(fg, -1, 1).type_name == "integral"
    @test derivative(fg).type_name == "derivative"
    @test riemannsum(sin, 10, "lower").type_name == "riemannsum"
    @test slopefield(:(x -> x^2)).type_name == "slopefield"
    @test vectorfield(:(x -> x^2)).type_name == "vectorfield"

    # functiongraph with attributes
    fg3 = functiongraph(sin; color="red", strokeWidth=3)
    @test fg3.attributes["strokeColor"] == "red"
    @test fg3.attributes["strokeWidth"] == 3

    # String-based function graph (expression body → wrapped in function)
    fg_str = functiongraph("Math.sin(x)")
    @test fg_str.parents[1] isa JSFunction
    @test fg_str.parents[1].code == "function(x){return Math.sin(x);}"

    # String-based function graph (already a function → used as-is)
    fg_fn = functiongraph("function(x){ return x*x; }")
    @test fg_fn.parents[1] isa JSFunction
    @test fg_fn.parents[1].code == "function(x){ return x*x; }"

    # String-based slopefield (2-param: function(x,y) wrapper)
    sf_str = slopefield("x - y")
    @test sf_str.parents[1] isa JSFunction
    @test sf_str.parents[1].code == "function(x,y){return x - y;}"

    # String-based implicitcurve (2-param: function(x,y) wrapper)
    ic_str = implicitcurve("x*x + y*y - 9")
    @test ic_str.parents[1] isa JSFunction
    @test ic_str.parents[1].code == "function(x,y){return x*x + y*y - 9;}"
end

@testset "Interactive Elements" begin
    # Slider
    s = slider([0, -3], [4, -3], [1, 2, 5])
    @test s isa JSXElement
    @test s.type_name == "slider"
    @test length(s.parents) == 3

    # Slider with attributes
    s2 = slider([0, -3], [4, -3], [1, 2, 5]; name="a")
    @test s2.attributes["name"] == "a"

    # Text
    t = text(0, 4, "Hello")
    @test t isa JSXElement
    @test t.type_name == "text"
    @test t.parents == Any[0, 4, "Hello"]

    # HTML with slider
    b = Board("test_slider")
    push!(b, s)
    html = html_string(b)
    @test occursin("create('slider'", html)

    # All 8 interactive constructors
    fg = functiongraph(sin)
    @test checkbox(0, 0, "Show").type_name == "checkbox"
    @test input(0, 0, "val", "Label").type_name == "input"
    @test button(0, 0, "Click", "handler()").type_name == "button"
    @test glider(0, 0, fg).type_name == "glider"
    @test tapemeasure([0, 0], [1, 1]).type_name == "tapemeasure"
    @test text(0, 0, "hi").type_name == "text"
    @test image("url.png", [0, 0], [1, 1]).type_name == "image"
end

@testset "Composition & Transformation Elements" begin
    p1 = point(0, 0)
    p2 = point(1, 0)
    p3 = point(0, 1)
    l = line(p1, p2)
    fg = functiongraph(sin)

    # --- group ---
    g = group(p1, p2, p3)
    @test g isa JSXElement
    @test g.type_name == "group"
    @test length(g.parents) == 3
    @test g.parents[1] === p1
    @test g.parents[2] === p2
    @test g.parents[3] === p3

    # group with attributes
    g2 = group(p1, p2; color="red")
    @test g2.attributes["strokeColor"] == "red"

    # --- transformation ---
    # Translation
    t = transformation("translate", 2, 3)
    @test t isa JSXElement
    @test t.type_name == "transformation"
    @test t.parents[1] == Any[2, 3]
    @test t.parents[2] == "translate"

    # Rotation around origin
    t2 = transformation("rotate", π/4)
    @test t2.type_name == "transformation"
    @test t2.parents[1] == Any[π/4]
    @test t2.parents[2] == "rotate"

    # Rotation around a point
    t3 = transformation("rotate", π/4, 1, 1)
    @test t3.type_name == "transformation"
    @test t3.parents[1] == Any[π/4, 1, 1]
    @test t3.parents[2] == "rotate"

    # Scale
    t4 = transformation("scale", 2, 3)
    @test t4.type_name == "transformation"
    @test t4.parents[2] == "scale"

    # --- reflection ---
    r = reflection(l)
    @test r isa JSXElement
    @test r.type_name == "reflection"
    @test r.parents[1] === l

    # reflection with attributes
    r2 = reflection(l; visible=false)
    @test r2.attributes["visible"] == false

    # --- rotation ---
    rot = rotation(p1, π/4)
    @test rot isa JSXElement
    @test rot.type_name == "rotation"
    @test rot.parents[1] === p1
    @test rot.parents[2] == π/4

    # --- translation ---
    tr = translation(2, 3)
    @test tr isa JSXElement
    @test tr.type_name == "translation"
    @test tr.parents == Any[2, 3]

    # --- grid ---
    gr = grid()
    @test gr isa JSXElement
    @test gr.type_name == "grid"
    @test isempty(gr.parents)

    # grid with attributes
    gr2 = grid(; majorStep=[1, 1])
    @test gr2.attributes["majorStep"] == [1, 1]

    # --- axis ---
    ax = axis(p1, p2)
    @test ax isa JSXElement
    @test ax.type_name == "axis"
    @test ax.parents[1] === p1
    @test ax.parents[2] === p2

    # axis with attributes
    ax2 = axis(p1, p2; name="x")
    @test ax2.attributes["name"] == "x"

    # --- ticks ---
    tk = ticks(ax, 1.0)
    @test tk isa JSXElement
    @test tk.type_name == "ticks"
    @test tk.parents[1] === ax
    @test tk.parents[2] == 1.0

    # ticks without distance
    tk2 = ticks(ax)
    @test tk2.type_name == "ticks"
    @test length(tk2.parents) == 1

    # ticks with attributes
    tk3 = ticks(ax, 2.0; minorTicks=4, drawLabels=true)
    @test tk3.attributes["minorTicks"] == 4
    @test tk3.attributes["drawLabels"] == true

    # --- legend ---
    fg2 = functiongraph(cos)
    leg = legend(fg, fg2; labels=["sin", "cos"])
    @test leg isa JSXElement
    @test leg.type_name == "legend"
    @test length(leg.parents) == 2
    @test leg.parents[1] === fg
    @test leg.parents[2] === fg2
    @test leg.attributes["labels"] == ["sin", "cos"]

    # --- HTML rendering ---
    b = Board("test_comp_trans")
    p_origin = point(0, 0)
    p_xdir = point(1, 0)
    push!(b, p_origin, p_xdir)
    push!(b, gr)
    push!(b, axis(p_origin, p_xdir))
    html = html_string(b)
    @test occursin("create('grid'", html)
    @test occursin("create('axis'", html)

    # All 9 composition/transformation constructors produce correct type_name
    @test group(p1).type_name == "group"
    @test transformation("translate", 1, 0).type_name == "transformation"
    @test reflection(l).type_name == "reflection"
    @test rotation(p1, π).type_name == "rotation"
    @test translation(1, 0).type_name == "translation"
    @test grid().type_name == "grid"
    @test axis(p1, p2).type_name == "axis"
    @test ticks(ax).type_name == "ticks"
    @test legend(fg).type_name == "legend"
end

@testset "Element JS Rendering" begin
    # Board with one point
    b = Board("test_el")
    p = point(1, 2)
    push!(b.elements, p)
    html = html_string(b)
    @test occursin("create('point'", html)
    @test occursin("[1,2]", html)

    # Two elements rendered in order
    b2 = Board("test_el2")
    p1 = point(0, 0)
    p2 = point(3, 4)
    push!(b2.elements, p1)
    push!(b2.elements, p2)
    html2 = html_string(b2)
    idx1 = findfirst("el_001", html2)
    idx2 = findfirst("el_002", html2)
    @test idx1 !== nothing
    @test idx2 !== nothing
    @test first(idx1) < first(idx2)

    # Element references: line referencing points
    b3 = Board("test_el3")
    pa = point(-1, 0)
    pb = point(1, 0)
    l = line(pa, pb)
    push!(b3.elements, pa)
    push!(b3.elements, pb)
    push!(b3.elements, l)
    html3 = html_string(b3)
    @test occursin("create('line'", html3)
    @test occursin("el_001", html3)
    @test occursin("el_002", html3)

    # Attributes appear as JSON
    b4 = Board("test_el4")
    p = point(1, 2; color="blue", size=5)
    push!(b4.elements, p)
    html4 = html_string(b4)
    @test occursin("\"strokeColor\"", html4)
    @test occursin("\"blue\"", html4)

    # text/plain display shows element count
    b5 = Board("test_el5")
    push!(b5.elements, point(0, 0))
    push!(b5.elements, point(1, 1))
    txt = sprint(show, MIME("text/plain"), b5)
    @test occursin("2 elements", txt)
end
