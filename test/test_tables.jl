using Tables

@testset "Tables.jl Data Ingestion" begin
    # Use NamedTuple of vectors (Tables.jl-compatible)
    data = (x=[1.0, 2.0, 3.0, 4.0], y=[1.0, 4.0, 9.0, 16.0])

    @testset "scatter with table" begin
        # Positional column names
        b = scatter(data, :x, :y)
        @test b isa Board
        @test length(b.elements) == 4
        @test all(e.type_name == "point" for e in b.elements)
        @test b.elements[1].parents == Any[1.0, 1.0]
        @test b.elements[4].parents == Any[4.0, 16.0]

        # Auto-detect first two columns
        b2 = scatter(data)
        @test length(b2.elements) == 4
        @test b2.elements[1].parents == Any[1.0, 1.0]

        # Explicit column keyword arguments
        b3 = scatter(data; x=:x, y=:y)
        @test length(b3.elements) == 4

        # Reversed columns
        b4 = scatter(data, :y, :x)
        @test b4.elements[1].parents == Any[1.0, 1.0]
        @test b4.elements[2].parents == Any[4.0, 2.0]

        # Passes attributes through
        b5 = scatter(data, :x, :y; color="red", size=5)
        @test b5.elements[1].attributes["strokeColor"] == "red"
        @test b5.elements[1].attributes["size"] == 5

        # HTML output works
        html = html_string(b)
        @test occursin("create('point'", html)
    end

    @testset "plot with table" begin
        # Positional column names
        b = plot(data, :x, :y)
        @test b isa Board
        @test length(b.elements) == 1
        @test b.elements[1].type_name == "curve"

        # Parents are data arrays
        parents = b.elements[1].parents
        @test parents[1] == [1.0, 2.0, 3.0, 4.0]
        @test parents[2] == [1.0, 4.0, 9.0, 16.0]

        # Auto-detect first two columns
        b2 = plot(data)
        @test length(b2.elements) == 1
        @test b2.elements[1].type_name == "curve"

        # Explicit column keyword arguments
        b3 = plot(data; x=:x, y=:y)
        @test length(b3.elements) == 1

        # Custom limits
        b4 = plot(data, :x, :y; xlim=(0, 5), ylim=(0, 20))
        bb = b4.options["boundingbox"]
        @test bb[1] == 0
        @test bb[3] == 5

        # Passes attributes through
        b5 = plot(data, :x, :y; color="blue", strokeWidth=3)
        @test b5.elements[1].attributes["strokeColor"] == "blue"
        @test b5.elements[1].attributes["strokeWidth"] == 3

        # HTML output contains curve
        html = html_string(b)
        @test occursin("create('curve'", html)
        # Data arrays appear in JS
        @test occursin("[1.0,2.0,3.0,4.0]", html)
    end

    @testset "table edge cases" begin
        # Three-column table, select specific columns
        data3 = (a=[1, 2, 3], b=[4, 5, 6], c=[7, 8, 9])
        b = scatter(data3, :a, :c)
        @test b.elements[1].parents == Any[1.0, 7.0]
        @test b.elements[3].parents == Any[3.0, 9.0]

        # Auto-detect uses first two columns
        b2 = scatter(data3)
        @test b2.elements[1].parents == Any[1.0, 4.0]

        # Integer data converts to Float64
        int_data = (x=[1, 2, 3], y=[10, 20, 30])
        b3 = scatter(int_data, :x, :y)
        @test b3.elements[1].parents == Any[1.0, 10.0]

        # Single-column table throws error
        single_col = (x=[1, 2, 3],)
        @test_throws ArgumentError scatter(single_col)
        @test_throws ArgumentError plot(single_col)

        # Vector of NamedTuples (row table)
        rows = [(x=1.0, y=2.0), (x=3.0, y=4.0), (x=5.0, y=6.0)]
        b4 = scatter(rows, :x, :y)
        @test length(b4.elements) == 3
        @test b4.elements[1].parents == Any[1.0, 2.0]
        @test b4.elements[3].parents == Any[5.0, 6.0]

        # plot with row table
        b5 = plot(rows, :x, :y)
        @test length(b5.elements) == 1
        @test b5.elements[1].type_name == "curve"
    end
end
