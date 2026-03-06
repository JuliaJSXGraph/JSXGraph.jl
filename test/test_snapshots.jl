"""
HTML Snapshot Tests (REQ-QA-002)

Compare generated HTML/JS output for major element types against reference snapshots
to detect unintended regressions.

Set `ENV["UPDATE_SNAPSHOTS"] = "true"` before running tests to regenerate reference files.
"""

const SNAPSHOT_DIR = joinpath(@__DIR__, "snapshots")

"""
    snapshot_test(name, board; asset_mode=:cdn)

Compare the HTML output of `board` against the stored snapshot `name.html`.
If `ENV["UPDATE_SNAPSHOTS"] == "true"`, overwrite the snapshot instead of comparing.
"""
function snapshot_test(name::String, board::Board; asset_mode::Symbol=:cdn)
    html = html_string(board; full_page=false, asset_mode=asset_mode)
    snapshot_path = joinpath(SNAPSHOT_DIR, "$(name).html")
    if get(ENV, "UPDATE_SNAPSHOTS", "false") == "true"
        mkpath(SNAPSHOT_DIR)
        open(snapshot_path, "w") do io
            write(io, html)
        end
        @info "Updated snapshot: $(name).html"
        @test true  # always pass when updating
    else
        if !isfile(snapshot_path)
            error(
                "Snapshot '$(name).html' not found. Run with " *
                "ENV[\"UPDATE_SNAPSHOTS\"]=\"true\" to generate it."
            )
        end
        expected = replace(read(snapshot_path, String), "\r\n" => "\n")
        @test html == expected
    end
end

@testset "HTML Snapshot Tests (REQ-QA-002)" begin
    @testset "Point" begin
        b = Board("snap_point", xlim=(-5, 5), ylim=(-5, 5))
        push!(b, point(1, 2; name="A", color="blue"))
        snapshot_test("point", b)
    end

    @testset "Line" begin
        b = Board("snap_line", xlim=(-5, 5), ylim=(-5, 5))
        p1 = point(0, 0; name="P1")
        p2 = point(3, 4; name="P2")
        push!(b, p1)
        push!(b, p2)
        push!(b, line(p1, p2; strokeColor="red"))
        snapshot_test("line", b)
    end

    @testset "Circle" begin
        b = Board("snap_circle", xlim=(-5, 5), ylim=(-5, 5))
        c = point(0, 0; name="Center")
        push!(b, c)
        push!(b, circle(c, 3; strokeColor="green"))
        snapshot_test("circle", b)
    end

    @testset "Polygon" begin
        b = Board("snap_polygon", xlim=(-5, 5), ylim=(-5, 5))
        p1 = point(0, 0; name="A")
        p2 = point(4, 0; name="B")
        p3 = point(2, 3; name="C")
        push!(b, p1)
        push!(b, p2)
        push!(b, p3)
        push!(b, polygon(p1, p2, p3; fillColor="yellow", fillOpacity=0.3))
        snapshot_test("polygon", b)
    end

    @testset "Function Graph" begin
        b = Board("snap_functiongraph", xlim=(-5, 5), ylim=(-5, 5))
        push!(b, functiongraph("function(x){ return Math.sin(x); }"; strokeColor="purple"))
        snapshot_test("functiongraph", b)
    end

    @testset "Slider" begin
        b = Board("snap_slider", xlim=(-5, 5), ylim=(-5, 5))
        push!(b, slider([1, 4], [5, 4], [0, 1, 5]; name="s"))
        snapshot_test("slider", b)
    end

    @testset "Text" begin
        b = Board("snap_text", xlim=(-5, 5), ylim=(-5, 5))
        push!(b, text(1, 2, "Hello JSXGraph"; fontSize=16))
        snapshot_test("text", b)
    end

    @testset "Arc" begin
        b = Board("snap_arc", xlim=(-5, 5), ylim=(-5, 5))
        c = point(0, 0; name="C")
        p1 = point(3, 0; name="P1")
        p2 = point(0, 3; name="P2")
        push!(b, c)
        push!(b, p1)
        push!(b, p2)
        push!(b, arc(c, p1, p2; strokeColor="orange"))
        snapshot_test("arc", b)
    end

    @testset "Curve" begin
        b = Board("snap_curve", xlim=(-5, 5), ylim=(-5, 5))
        push!(b, curve(
            "function(t){ return 2*Math.cos(t); }",
            "function(t){ return 2*Math.sin(t); }",
            0, 6.28;
            strokeColor="teal"
        ))
        snapshot_test("curve", b)
    end

    @testset "Image" begin
        b = Board("snap_image", xlim=(-5, 5), ylim=(-5, 5))
        push!(b, image("https://example.com/img.png", [-3, -3], [6, 6]))
        snapshot_test("image", b)
    end
end
