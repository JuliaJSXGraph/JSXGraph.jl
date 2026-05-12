using JSXGraph
using Test

# Helper: render a board as a full HTML page with CDN-mode asset loading.
# Full-page mode keeps the inline JS unescaped (fragment+CDN mode wraps it
# in a JS string for delayed `eval`, which would JSON-encode every quote
# and make snapshot assertions brittle).
render(b) = JSXGraph.html_page(b; asset_mode=:cdn)

@testset "Pluto @bind integration" begin

    # =====================================================================
    # User Story 1 — Read interactive point positions (P1, MVP)
    # =====================================================================
    @testset "US1: 2D draggable points" begin

        # ---- T008: points_xy unit test (pure projection) ----
        @testset "points_xy projection" begin
            state = Dict{String,Any}(
                "A" => (x=1.0, y=2.0),
                "B" => (x=-1.0, y=0.5),
                "C" => 0.7,  # slider — must be skipped
                "_order" => ["A", "B", "C"],
            )
            xs, ys = points_xy(state)
            @test xs == [1.0, -1.0]
            @test ys == [2.0, 0.5]

            # Empty state
            @test points_xy(Dict{String,Any}()) == (Float64[], Float64[])

            # Dict-shaped values (post-JSON-decode) work too
            state2 = Dict{String,Any}(
                "A" => Dict("x" => 3.0, "y" => 4.0),
                "_order" => ["A"],
            )
            xs2, ys2 = points_xy(state2)
            @test xs2 == [3.0]
            @test ys2 == [4.0]

            # First-run tolerance: @bind may deliver nothing/missing
            # before the browser publishes; downstream cells must not
            # crash.
            @test points_xy(nothing) == (Float64[], Float64[])
            @test points_xy(missing) == (Float64[], Float64[])
            @test points_xyz(nothing) == (Float64[], Float64[], Float64[])
            @test points_xyz(missing) == (Float64[], Float64[], Float64[])
        end

        @testset "_initial_bound_state seeds from element parents" begin
            b = JSXGraph.Board("seed_init"; xlim=(-5, 5), ylim=(-5, 5), bindable=true)
            push!(b, point(1.5, 2.5; name="A"))
            push!(b, point(-1.0, 0.0))  # auto-id
            push!(b, slider([-4, -3], [4, -3], [-2, 0.3, 2]; name="k"))
            seed = JSXGraph._initial_bound_state(b)
            @test seed["A"] == (x = 1.5, y = 2.5)
            @test seed["point_1"] == (x = -1.0, y = 0.0)
            @test seed["k"] == 0.3
        end

        # ---- T006: bindable=false byte-identical to no kwarg ----
        @testset "bindable=false is byte-identical to default" begin
            b1 = JSXGraph.Board("regress"; xlim=(-5, 5), ylim=(-5, 5))
            push!(b1, point(1.0, 2.0; name="A"))
            b2 = JSXGraph.Board("regress"; xlim=(-5, 5), ylim=(-5, 5), bindable=false)
            push!(b2, point(1.0, 2.0; name="A"))
            @test render(b1) == render(b2)
        end

        # ---- T007: bindable=true emits the wrapper + state-publishing JS ----
        @testset "bindable=true emits wrapper, throttle, and input event" begin
            b = JSXGraph.Board("demo"; xlim=(-5, 5), ylim=(-5, 5), bindable=true)
            push!(b, point(1.0, 2.0; name="A"))
            html = render(b)
            @test occursin("class=\"jxg-bindable\"", html)
            @test occursin("board_demo.on('update'", html)
            @test occursin("CustomEvent(\"input\"", html)
            @test occursin("bubbles: true", html)
            @test occursin("33", html)  # throttle interval in ms
            @test occursin("mouseup", html)
            @test occursin("pointerup", html)
            @test occursin("touchend", html)
        end

        # ---- T009: duplicate names raise ArgumentError ----
        @testset "duplicate names raise ArgumentError" begin
            b = JSXGraph.Board("dup"; xlim=(-5, 5), ylim=(-5, 5), bindable=true)
            push!(b, point(0.0, 0.0; name="X"))
            @test_throws ArgumentError push!(b, point(1.0, 1.0; name="X"))
        end

        # ---- T010: seed coordinates appear in the rendered JS ----
        @testset "seed state values appear in emitted JS" begin
            b = JSXGraph.Board("seed"; xlim=(-5, 5), ylim=(-5, 5), bindable=true)
            push!(b, point(1.5, 2.5; name="A"))
            html = render(b)
            # The point is created with parents [1.5, 2.5] — those numerals
            # must appear in the generated element-creation call.
            @test occursin("1.5", html)
            @test occursin("2.5", html)
            # The element's bound-state key must appear in the seed-order array.
            @test occursin("\"A\"", html)
        end
    end

    # =====================================================================
    # User Story 2 — Slider values (P2)  [tests added in T017–T018]
    # =====================================================================
    @testset "US2: slider values in bound state" begin
        # T017
        @testset "slider element is emitted with kind:'slider' and Value()" begin
            b = JSXGraph.Board("sl"; xlim=(-5, 5), ylim=(-5, 5), bindable=true)
            push!(b, slider([-4, -3], [4, -3], [-2, 0.0, 2]; name="k"))
            html = render(b)
            @test occursin("kind: \"slider\"", html) || occursin("kind:'slider'", html)
            @test occursin(".Value()", html)
            @test occursin("\"k\"", html)
        end

        # T018
        @testset "mixed point + slider board" begin
            b = JSXGraph.Board("mix"; xlim=(-5, 5), ylim=(-5, 5), bindable=true)
            push!(b, point(0.0, 0.0; name="P"))
            push!(b, slider([-4, -3], [4, -3], [-2, 0.0, 2]; name="k"))
            html = render(b)
            @test occursin("\"P\"", html)
            @test occursin("\"k\"", html)
        end
    end

    # =====================================================================
    # User Story 3 — 3D points, points_xyz, AbstractPlutoDingetjes ext
    # =====================================================================
    @testset "US3: 3D points, points_xyz, extension" begin
        # T021
        @testset "points_xyz projection" begin
            state = Dict{String,Any}(
                "P" => (x=1.0, y=2.0, z=3.0),
                "Q" => (x=-1.0, y=0.0, z=0.5),
                "flat" => (x=9.0, y=9.0),  # 2D — must be skipped
                "k" => 0.5,                 # slider — must be skipped
                "_order" => ["P", "Q", "flat", "k"],
            )
            xs, ys, zs = points_xyz(state)
            @test xs == [1.0, -1.0]
            @test ys == [2.0, 0.0]
            @test zs == [3.0, 0.5]
        end

        # T023 — HTML snapshot for a bindable board with one 3D point
        @testset "bindable board with a 3D point emits kind:'point3d'" begin
            b = JSXGraph.Board("d3"; xlim=(-5, 5), ylim=(-5, 5), bindable=true)
            v = view3d([-6, -3], [8, 8], [[-3, 3], [-3, 3], [-3, 3]])
            push!(v, point3d(1.0, 2.0, 3.0; name="P"))
            push!(b, v)
            html = render(b)
            @test occursin("kind: \"point3d\"", html) || occursin("kind:'point3d'", html)
            @test occursin("\"P\"", html)
        end

        # T022 — extension override is wired when AbstractPlutoDingetjes
        # is loaded. The extension registers a Pluto-aware publisher in
        # `JSXGraph._SEED_PUBLISHER`. Outside a real Pluto IO context
        # the registered publisher gracefully falls back to JSON output
        # (FR-008), so the rendered HTML still works.
        @testset "extension registers Pluto seed publisher when loaded" begin
            if Base.find_package("AbstractPlutoDingetjes") === nothing
                @test_skip "AbstractPlutoDingetjes not installed in test env"
            else
                @eval Main using AbstractPlutoDingetjes
                @test JSXGraph._SEED_PUBLISHER[] !== nothing
                # And the registered publisher produces valid output
                # (JSON fallback in this non-Pluto context).
                buf = IOBuffer()
                JSXGraph._publish_seed_data(buf, ["A", "B"])
                out = String(take!(buf))
                @test !isempty(out)
            end
        end
    end

end
