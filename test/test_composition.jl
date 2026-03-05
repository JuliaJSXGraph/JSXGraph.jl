@testset "Board Composition" begin
    # push! adds element and returns board
    b = Board("comp1")
    p = point(1, 2)
    result = push!(b, p)
    @test result === b
    @test length(b.elements) == 1
    @test b.elements[1] === p

    # push! variadic
    b2 = Board("comp2")
    p1 = point(0, 0)
    p2 = point(1, 1)
    push!(b2, p1, p2)
    @test length(b2.elements) == 2

    # + returns new board, original unchanged
    b3 = Board("comp3")
    p = point(1, 2)
    new_b = b3 + p
    @test length(b3.elements) == 0
    @test length(new_b.elements) == 1
    @test new_b.elements[1] === p

    # + chains correctly
    b4 = Board("comp4")
    p1 = point(0, 0)
    p2 = point(1, 1)
    p3 = point(2, 2)
    result = b4 + p1 + p2 + p3
    @test length(result.elements) == 3
    @test length(b4.elements) == 0

    # Board with elements added via + generates valid HTML
    b5 = Board("comp5")
    result = b5 + point(1, 2) + point(3, 4)
    html = html_string(result)
    @test occursin("create('point'", html)
    @test occursin("el_001", html)
    @test occursin("el_002", html)
end

@testset "High-Level Plot" begin
    # Returns a Board
    b = plot(sin, (-5, 5))
    @test b isa Board

    # Has exactly one functiongraph element
    @test length(b.elements) == 1
    @test b.elements[1].type_name == "functiongraph"

    # Bounding box x-range matches domain
    bb = b.options["boundingbox"]
    @test bb[1] == -5  # xmin
    @test bb[3] == 5   # xmax

    # Passes attributes to element
    b2 = plot(sin, (-5, 5); color="red")
    @test b2.elements[1].attributes["strokeColor"] == "red"

    # Zero-width domain throws error
    @test_throws ArgumentError plot(sin, (0, 0))

    # HTML output contains JS function
    html = html_string(b)
    @test occursin("Math.sin", html)
    @test occursin("create('functiongraph'", html)
end

@testset "scatter" begin
    # Basic scatter plot
    b = scatter([1, 2, 3], [4, 5, 6])
    @test b isa Board
    @test length(b.elements) == 3
    @test all(e.type_name == "point" for e in b.elements)

    # Points have correct coordinates
    @test b.elements[1].parents == Any[1, 4]
    @test b.elements[2].parents == Any[2, 5]
    @test b.elements[3].parents == Any[3, 6]

    # Auto-computed bounding box with padding
    bb = b.options["boundingbox"]
    @test bb[1] < 1   # xmin has padding
    @test bb[3] > 3   # xmax has padding
    @test bb[2] > 6   # ymax has padding
    @test bb[4] < 4   # ymin has padding

    # Explicit xlim/ylim
    b2 = scatter([1, 2], [3, 4]; xlim=(0, 10), ylim=(0, 10))
    bb2 = b2.options["boundingbox"]
    @test bb2[1] == 0
    @test bb2[3] == 10

    # Passes attributes to points
    b3 = scatter([1.0], [2.0]; color="red", size=5)
    @test b3.elements[1].attributes["strokeColor"] == "red"
    @test b3.elements[1].attributes["size"] == 5

    # Single point with equal x/y gets 1.0 padding
    b4 = scatter([5], [5])
    bb4 = b4.options["boundingbox"]
    @test bb4[1] == 4.0  # 5 - 1.0
    @test bb4[3] == 6.0  # 5 + 1.0

    # Mismatched lengths throw
    @test_throws ArgumentError scatter([1, 2], [1])

    # Empty vectors throw
    @test_throws ArgumentError scatter(Int[], Int[])

    # HTML output contains points
    html = html_string(scatter([0, 1], [0, 1]))
    @test occursin("create('point'", html)
end

@testset "parametric" begin
    # Basic parametric curve (unit circle)
    b = parametric(cos, sin, (0, 2π))
    @test b isa Board
    @test length(b.elements) == 1
    @test b.elements[1].type_name == "curve"

    # Parents include JSFunction for fx, fy and range bounds
    parents = b.elements[1].parents
    @test parents[1] isa JSFunction  # fx
    @test parents[2] isa JSFunction  # fy
    @test parents[3] == 0            # t_start
    @test parents[4] ≈ 2π           # t_end

    # Custom limits
    b2 = parametric(cos, sin, (0, 2π); xlim=(-2, 2), ylim=(-2, 2))
    bb = b2.options["boundingbox"]
    @test bb[1] == -2
    @test bb[3] == 2

    # Passes attributes
    b3 = parametric(cos, sin, (0, 2π); color="blue")
    @test b3.elements[1].attributes["strokeColor"] == "blue"

    # Zero-width range throws
    @test_throws ArgumentError parametric(cos, sin, (0, 0))

    # HTML output
    html = html_string(b)
    @test occursin("create('curve'", html)
end

@testset "implicit" begin
    # Basic implicit curve (unit circle: x² + y² - 1 = 0)
    b = implicit(:((x, y) -> x^2 + y^2 - 1))
    @test b isa Board
    @test length(b.elements) == 1
    @test b.elements[1].type_name == "implicitcurve"

    # Custom limits
    b2 = implicit(:((x, y) -> x^2 + y^2 - 4); xlim=(-3, 3), ylim=(-3, 3))
    bb = b2.options["boundingbox"]
    @test bb[1] == -3
    @test bb[3] == 3

    # Passes attributes
    b3 = implicit(:((x, y) -> x^2 + y^2 - 1); color="green")
    @test b3.elements[1].attributes["strokeColor"] == "green"

    # HTML output
    html = html_string(b)
    @test occursin("create('implicitcurve'", html)
end

@testset "polar" begin
    # Basic polar curve (cardioid)
    b = polar(:(θ -> 1 + cos(θ)))
    @test b isa Board
    @test length(b.elements) == 1
    @test b.elements[1].type_name == "curve"

    # Parents are JSFunction (parametric x and y) + range
    parents = b.elements[1].parents
    @test parents[1] isa JSFunction  # x(θ) = r(θ)*cos(θ)
    @test parents[2] isa JSFunction  # y(θ) = r(θ)*sin(θ)
    @test parents[3] == 0            # θ_start
    @test parents[4] ≈ 2π           # θ_end

    # Generated JS wraps r(θ) in cos/sin
    @test occursin("Math.cos(t)", parents[1].code)
    @test occursin("Math.sin(t)", parents[2].code)

    # Custom θ range
    b2 = polar(:(θ -> θ), (0, 4π))
    @test b2.elements[1].parents[4] ≈ 4π

    # Custom limits
    b3 = polar(:(θ -> 1); xlim=(-2, 2), ylim=(-2, 2))
    bb = b3.options["boundingbox"]
    @test bb[1] == -2
    @test bb[3] == 2

    # Passes attributes
    b4 = polar(:(θ -> 1 + cos(θ)); color="red")
    @test b4.elements[1].attributes["strokeColor"] == "red"

    # Zero-width range throws
    @test_throws ArgumentError polar(:(θ -> 1), (0, 0))

    # Use with a Julia function (constant radius)
    b5 = polar(:(θ -> 2))
    html = html_string(b5)
    @test occursin("create('curve'", html)
end

@testset "board do-block" begin
    # Basic do-block creates a board with elements
    b = board("dotest1", xlim=(-5, 5), ylim=(-5, 5)) do b
        push!(b, point(1, 2))
        push!(b, point(3, 4))
    end
    @test b isa Board
    @test b.id == "dotest1"
    @test length(b.elements) == 2
    @test b.elements[1].type_name == "point"
    @test b.elements[2].type_name == "point"

    # Board options are passed through
    bb = b.options["boundingbox"]
    @test bb[1] == -5
    @test bb[3] == 5

    # Default empty id (auto-generated)
    b2 = board(xlim=(-10, 10)) do b
        push!(b, functiongraph(sin))
    end
    @test b2 isa Board
    @test startswith(b2.id, "jxg_")
    @test length(b2.elements) == 1
    @test b2.elements[1].type_name == "functiongraph"

    # Empty do-block returns empty board
    b3 = board("empty") do b
        nothing
    end
    @test b3 isa Board
    @test length(b3.elements) == 0

    # Can use variadic push! inside do-block
    b4 = board("multi") do b
        push!(b, point(0, 0), point(1, 1), point(2, 2))
    end
    @test length(b4.elements) == 3

    # Can use + operator inside do-block (non-mutating, must reassign)
    b5 = board("plus") do b
        push!(b, point(1, 2))
        push!(b, line(point(0, 0), point(1, 1)))
    end
    @test length(b5.elements) == 2

    # Board options: grid, axis, width, height
    b6 = board("opts", grid=true, axis=false, width=800, height=600) do b
        push!(b, point(0, 0))
    end
    @test b6.options["grid"] == true
    @test b6.options["axis"] == false
    @test b6.options["width"] == 800
    @test b6.options["height"] == 600

    # HTML output works correctly
    b7 = board("htmltest", xlim=(-2, 2)) do b
        push!(b, point(1, 1; name="A"))
        push!(b, functiongraph(cos; color="blue"))
    end
    html = html_string(b7)
    @test occursin("htmltest", html)
    @test occursin("create('point'", html)
    @test occursin("create('functiongraph'", html)
end
