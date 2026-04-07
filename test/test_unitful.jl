using Unitful

@testset "Unitful.jl Integration" begin
    @testset "point with Unitful quantities" begin
        p = point(1.0u"m", 2.0u"s")
        @test p isa JSXElement
        @test p.type_name == "point"
        @test p.parents == Any[1.0, 2.0]
    end

    @testset "scatter with Unitful vectors" begin
        x = [1.0, 2.0, 3.0, 4.0]u"m"
        y = [0.5, 1.0, 1.5, 2.0]u"s"

        b = scatter(x, y)
        @test b isa Board
        @test length(b.elements) == 4
        @test all(e.type_name == "point" for e in b.elements)

        # Values are stripped of units
        @test b.elements[1].parents == Any[1.0, 0.5]
        @test b.elements[4].parents == Any[4.0, 2.0]

        # Axis labels include units
        da = b.options["defaultAxes"]
        @test occursin("m", da["x"]["name"])
        @test occursin("s", da["y"]["name"])
        @test da["x"]["withLabel"] == true
        @test da["y"]["withLabel"] == true

        # Custom axis label names
        b2 = scatter(x, y; xlabel="distance", ylabel="time")
        da2 = b2.options["defaultAxes"]
        @test da2["x"]["name"] == "distance (m)"
        @test da2["y"]["name"] == "time (s)"

        # Passes styling through
        b3 = scatter(x, y; color="red")
        @test b3.elements[1].attributes["strokeColor"] == "red"

        # HTML output contains point elements
        html = html_string(b)
        @test occursin("create('point'", html)
    end

    @testset "scatter with unit conversion" begin
        # Mixed compatible units: cm and m → converted to first element's unit
        x = [100.0u"cm", 200.0u"cm", 300.0u"cm"]
        y = [1.0u"m", 2.0u"m", 3.0u"m"]

        b = scatter(x, y)
        @test b.elements[1].parents == Any[100.0, 1.0]
        @test b.elements[3].parents == Any[300.0, 3.0]

        # convert mm to m
        x_mixed = [1.0u"m", 2000.0u"mm", 3.0u"m"]
        y_plain = [1.0u"s", 2.0u"s", 3.0u"s"]
        b2 = scatter(x_mixed, y_plain)
        @test b2.elements[1].parents[1] ≈ 1.0
        @test b2.elements[2].parents[1] ≈ 2.0  # 2000 mm → 2.0 m
        @test b2.elements[3].parents[1] ≈ 3.0
    end

    @testset "plot with Unitful domain" begin
        b = plot(sin, (-5u"m", 5u"m"))
        @test b isa Board
        @test length(b.elements) == 1
        @test b.elements[1].type_name == "functiongraph"

        # Bounding box has stripped values
        bb = b.options["boundingbox"]
        @test bb[1] == -5  # xmin
        @test bb[3] == 5   # xmax

        # Axis label includes unit
        da = b.options["defaultAxes"]
        @test occursin("m", da["x"]["name"])

        # Custom xlabel
        b2 = plot(sin, (-5u"m", 5u"m"); xlabel="distance")
        @test b2.options["defaultAxes"]["x"]["name"] == "distance (m)"

        # HTML output works
        html = html_string(b)
        @test occursin("create('functiongraph'", html)
    end

    @testset "Board with Unitful limits" begin
        b = Board("unitful_test",
                  (0u"m", 10u"m"),
                  (0u"s", 5u"s"))
        @test b isa Board
        @test b.id == "unitful_test"

        # Bounding box has stripped values
        bb = b.options["boundingbox"]
        @test bb[1] == 0    # xmin
        @test bb[3] == 10   # xmax
        @test bb[2] == 5    # ymax
        @test bb[4] == 0    # ymin

        # Axis labels
        da = b.options["defaultAxes"]
        @test occursin("m", da["x"]["name"])
        @test occursin("s", da["y"]["name"])

        # Custom axis names
        b2 = Board("test2",
                   (0u"km", 100u"km"),
                   (0u"kg", 50u"kg");
                   xlabel="distance", ylabel="mass")
        da2 = b2.options["defaultAxes"]
        @test da2["x"]["name"] == "distance (km)"
        @test da2["y"]["name"] == "mass (kg)"
    end

    @testset "defaultAxes renders in HTML" begin
        x = [1.0, 2.0, 3.0]u"m"
        y = [4.0, 5.0, 6.0]u"s"
        b = scatter(x, y)
        html = html_string(b)
        # defaultAxes should appear in the JS options
        @test occursin("defaultAxes", html)
    end
end
