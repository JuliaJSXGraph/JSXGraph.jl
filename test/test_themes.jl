@testset "Theming System" begin
    # Ensure clean state at start
    reset_theme!()

    @testset "Default Theme" begin
        reset_theme!()
        @test isempty(current_theme())

        # Elements have no extra attributes from theme
        p = point(1, 2)
        @test !haskey(p.attributes, "fillColor")
    end

    @testset "set_theme! with Symbol" begin
        reset_theme!()

        set_theme!(:dark)
        @test current_theme() === THEME_DARK

        set_theme!(:publication)
        @test current_theme() === THEME_PUBLICATION

        set_theme!(:default)
        @test isempty(current_theme())

        # Invalid theme name
        @test_throws ArgumentError set_theme!(:nonexistent)

        reset_theme!()
    end

    @testset "set_theme! with Theme dict" begin
        reset_theme!()

        custom = JSXGraph.Theme(
            "point" => Dict{String,Any}("strokeColor" => "purple", "size" => 10),
        )
        set_theme!(custom)
        @test current_theme() === custom

        p = point(1, 2)
        @test p.attributes["strokeColor"] == "purple"
        @test p.attributes["size"] == 10

        reset_theme!()
    end

    @testset "reset_theme!" begin
        set_theme!(:dark)
        @test !isempty(current_theme())

        reset_theme!()
        @test isempty(current_theme())
    end

    @testset "with_theme block" begin
        reset_theme!()
        @test isempty(current_theme())

        with_theme(:dark) do
            @test current_theme() === THEME_DARK
            p = point(1, 2)
            @test p.attributes["fillColor"] == "#ff6b6b"
        end

        # Theme is restored after with_theme
        @test isempty(current_theme())

        # Invalid theme
        @test_throws ArgumentError with_theme(:nonexistent) do
            nothing
        end
    end

    @testset "with_theme restores on error" begin
        reset_theme!()

        try
            with_theme(:dark) do
                error("intentional")
            end
        catch
        end

        # Theme must be restored even after error
        @test isempty(current_theme())
    end

    @testset "Dark Theme Element Defaults" begin
        reset_theme!()
        set_theme!(:dark)

        p = point(1, 2)
        @test p.attributes["strokeColor"] == "#ff6b6b"
        @test p.attributes["fillColor"] == "#ff6b6b"

        l = line(p, point(3, 4))
        @test l.attributes["strokeColor"] == "#4ecdc4"
        @test l.attributes["strokeWidth"] == 2

        fg = functiongraph(sin)
        @test fg.attributes["strokeColor"] == "#ffd93d"

        c = circle(p, 3)
        @test c.attributes["strokeColor"] == "#45b7d1"

        reset_theme!()
    end

    @testset "Publication Theme Element Defaults" begin
        reset_theme!()
        set_theme!(:publication)

        p = point(1, 2)
        @test p.attributes["strokeColor"] == "#000000"
        @test p.attributes["fillColor"] == "#000000"
        @test p.attributes["size"] == 2

        fg = functiongraph(sin)
        @test fg.attributes["strokeColor"] == "#000000"
        @test fg.attributes["strokeWidth"] == 2

        reset_theme!()
    end

    @testset "Global Theme Defaults" begin
        set_theme!(:publication)

        # segment is not explicitly in publication theme, uses global defaults
        s = segment(point(0, 0), point(1, 1))
        @test s.attributes["strokeColor"] == "#000000"
        @test s.attributes["strokeWidth"] == 1.5

        reset_theme!()
    end

    @testset "User Kwargs Override Theme" begin
        set_theme!(:dark)

        # User color alias overrides theme default
        p = point(1, 2; color="green")
        @test p.attributes["strokeColor"] == "green"

        # User native attr overrides theme
        l = line(point(0, 0), point(1, 1); strokeColor="red")
        @test l.attributes["strokeColor"] == "red"

        # User strokeWidth overrides theme
        fg = functiongraph(sin; strokeWidth=5)
        @test fg.attributes["strokeWidth"] == 5

        reset_theme!()
    end

    @testset "Board Theme Defaults" begin
        set_theme!(:dark)

        b = Board("test_theme_board")
        @test b.options["background"] == "#2d2d2d"

        # User options override board theme
        b2 = Board("test_theme_board2"; background="#fff")
        @test b2.options["background"] == "#fff"

        reset_theme!()

        # No board theme with default theme
        b3 = Board("test_no_theme")
        @test !haskey(b3.options, "background")
    end

    @testset "register_theme!" begin
        reset_theme!()

        my_theme = JSXGraph.Theme(
            "point" => Dict{String,Any}("fillColor" => "orange"),
        )
        register_theme!(:custom_test, my_theme)

        set_theme!(:custom_test)
        p = point(1, 2)
        @test p.attributes["fillColor"] == "orange"

        # Clean up
        delete!(JSXGraph.THEME_REGISTRY, :custom_test)
        reset_theme!()
    end

    @testset "Load Theme from TOML" begin
        reset_theme!()

        toml_content = """
        [global]
        strokeColor = "#112233"

        [point]
        size = 7
        fillColor = "#aabbcc"
        """

        tmpfile = tempname() * ".toml"
        write(tmpfile, toml_content)

        theme = load_theme(tmpfile)
        @test theme["global"]["strokeColor"] == "#112233"
        @test theme["point"]["size"] == 7
        @test theme["point"]["fillColor"] == "#aabbcc"

        # Use the loaded theme
        set_theme!(theme)
        p = point(1, 2)
        @test p.attributes["fillColor"] == "#aabbcc"
        @test p.attributes["size"] == 7
        @test p.attributes["strokeColor"] == "#112233"  # from global

        rm(tmpfile)
        reset_theme!()
    end

    @testset "Load Theme from JSON" begin
        json_content = """
        {
            "point": {"strokeColor": "#ff0000", "size": 5},
            "line": {"strokeWidth": 3}
        }
        """

        tmpfile = tempname() * ".json"
        write(tmpfile, json_content)

        theme = load_theme(tmpfile)
        @test theme["point"]["strokeColor"] == "#ff0000"
        @test theme["point"]["size"] == 5
        @test theme["line"]["strokeWidth"] == 3

        rm(tmpfile)
    end

    @testset "Invalid Theme File" begin
        @test_throws ArgumentError load_theme("theme.xyz")
    end

    @testset "Theme with HTML Rendering" begin
        set_theme!(:dark)

        b = Board("test_theme_html")
        p = point(1, 2)
        push!(b, p)
        html = html_string(b)

        # Element attributes from theme should appear in HTML
        @test occursin("\"strokeColor\"", html)
        @test occursin("#ff6b6b", html)

        reset_theme!()
    end

    # Final cleanup
    reset_theme!()
end
