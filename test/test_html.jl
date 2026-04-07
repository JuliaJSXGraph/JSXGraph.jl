@testset "HTML Generation" begin
    board = Board("test")

    # Returns a String
    result = html_string(board)
    @test result isa String

    # Full page output
    @test occursin("<!DOCTYPE html>", result)
    @test occursin("<div id=\"test\"", result)
    @test occursin("jxgbox", result)
    @test occursin("JXG.JSXGraph.initBoard", result)
    @test occursin("boundingbox", result)

    # Fragment mode
    frag = html_string(board; full_page=false)
    @test !occursin("<!DOCTYPE", frag)

    # Convenience functions
    @test html_page(board) == html_string(board; full_page=true)
    @test html_fragment(board) == html_string(board; full_page=false)

    # Grid option passes through
    board_grid = Board("test_grid", grid=true)
    html_grid = html_string(board_grid)
    @test occursin("\"grid\"", html_grid)
    @test occursin("true", html_grid)
end

@testset "Asset Loading" begin
    # Version constant
    @test JSXGRAPH_VERSION == "1.12.2"

    # JS artifact content
    js_content = JSXGraph.jsxgraph_js()
    @test !isempty(js_content)
    @test occursin("JSXGraph", js_content)

    # CSS artifact content
    css_content = JSXGraph.jsxgraph_css()
    @test !isempty(css_content)
    @test occursin("jxgbox", css_content)

    # Inline HTML embeds full JS (output should be large)
    inline_html = html_string(Board("test"))
    @test length(inline_html) > 100_000

    # Inline HTML contains style tag with CSS
    @test occursin("<style>", inline_html)
end

@testset "CDN Mode" begin
    # CDN output returns a String
    cdn_html = html_string(Board("test"); asset_mode=:cdn)
    @test cdn_html isa String

    # Contains CDN references
    @test occursin("cdn.jsdelivr.net", cdn_html)
    @test occursin("<script", cdn_html)
    @test occursin("src=", cdn_html)
    @test occursin("<link rel=", cdn_html)

    # CDN output is small (no embedded JS)
    @test length(cdn_html) < 10_000

    # CDN is at least 80% smaller than inline
    inline_html = html_string(Board("test"); asset_mode=:inline)
    @test length(cdn_html) < 0.2 * length(inline_html)

    # Invalid mode throws ArgumentError
    @test_throws ArgumentError html_string(Board("test"); asset_mode=:invalid)
end

@testset "save() to File" begin
    board = Board("save_test")
    push!(board, point(1, 2))

    # Inline mode (default)
    tmpfile = tempname() * ".html"
    result = save(tmpfile, board)
    @test result == tmpfile
    @test isfile(tmpfile)
    content = read(tmpfile, String)
    @test occursin("<!DOCTYPE html>", content)
    @test occursin("jxgbox", content)
    @test occursin("JXG.JSXGraph.initBoard", content)
    @test occursin("create('point'", content)
    @test length(content) > 100_000  # inline assets are large
    rm(tmpfile)

    # CDN mode
    tmpfile_cdn = tempname() * ".html"
    save(tmpfile_cdn, board; asset_mode=:cdn)
    cdn_content = read(tmpfile_cdn, String)
    @test occursin("cdn.jsdelivr.net", cdn_content)
    @test length(cdn_content) < 10_000
    rm(tmpfile_cdn)

    # Returns the filename
    tmpfile2 = tempname() * ".html"
    @test save(tmpfile2, board) == tmpfile2
    rm(tmpfile2)
end

@testset "HTML Size Warning (REQ-PERF-003)" begin
    # Small board should not warn
    b = Board("small")
    push!(b, point(1, 2))
    @test_nowarn html_string(b)
    @test_nowarn html_string(b; asset_mode=:cdn)

    # Verify threshold constant exists
    @test JSXGraph.HTML_SIZE_THRESHOLD == 1_048_576

    # Board with artificially large content should warn
    b_large = Board("large")
    # Add many elements with long attribute values to exceed 1 MB of content
    for i in 1:5000
        push!(b_large, text(0, 0, repeat("x", 250); name="t_$i"))
    end
    @test_warn r"exceeds the 1 MB threshold" html_string(b_large; asset_mode=:cdn)
    @test_warn r"exceeds the 1 MB threshold" html_string(b_large; asset_mode=:inline)
end
