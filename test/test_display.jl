@testset "HTML MIME Display" begin
    board = Board("test")
    html = sprint(show, MIME("text/html"), board)

    # Returns non-empty string
    @test !isempty(html)

    # Fragment mode (no DOCTYPE)
    @test !occursin("<!DOCTYPE", html)

    # CDN mode
    @test occursin("cdn.jsdelivr.net", html)

    # Contains div with jxgbox class
    @test occursin("<div id=", html)
    @test occursin("jxgbox", html)

    # Contains initBoard
    @test occursin("JXG.JSXGraph.initBoard", html)

    # Contains CDN script tag and link tags
    @test occursin("<script", html)
    @test occursin("<link rel=", html)
    # CDN JS is loaded via RequireJS-compatible loader (not a direct <script src>)
    @test occursin("require", html) || occursin("src=", html)
end

@testset "Unique Display IDs" begin
    board = Board("test")

    # Two display calls produce different div IDs
    html1 = sprint(show, MIME("text/html"), board)
    html2 = sprint(show, MIME("text/html"), board)

    # Extract display IDs
    m1 = match(r"id=\"(jxg_[a-zA-Z0-9]+)\"", html1)
    m2 = match(r"id=\"(jxg_[a-zA-Z0-9]+)\"", html2)
    @test m1 !== nothing
    @test m2 !== nothing
    @test m1[1] != m2[1]

    # Original board.id should NOT appear as div id
    @test !occursin("id=\"test\"", html1)

    # Display IDs match expected pattern (jxg_ + 12 chars)
    @test length(m1[1]) == 16  # "jxg_" (4) + 12 chars
end

@testset "Plain Text Display" begin
    board = Board("test")
    txt = sprint(show, MIME("text/plain"), board)

    # Contains board ID
    @test occursin("Board(\"test\"", txt)

    # Contains element count
    @test occursin("0 elements", txt)

    # Contains dimensions
    @test occursin("500x500px", txt)

    # Custom xlim/ylim
    board2 = Board("b2", xlim=(-10, 10), ylim=(-5, 5))
    txt2 = sprint(show, MIME("text/plain"), board2)
    @test occursin("x=[-10,10]", txt2) || occursin("x=[-10, 10]", txt2)
    @test occursin("y=[-5,5]", txt2) || occursin("y=[-5, 5]", txt2)

    # Single line (no embedded newlines)
    @test !occursin("\n", rstrip(txt))
end

@testset "Fragment Embedding" begin
    board = Board("test")
    html = sprint(show, MIME("text/html"), board)

    # No full page wrappers
    @test !occursin("<html>", html)
    @test !occursin("<body>", html)

    # CDN mode output is compact (under 2000 bytes)
    @test length(html) < 2000

    # Contains all necessary fragment elements
    @test occursin("<link", html)
    @test occursin("<script", html)
    @test occursin("<div", html)
    @test occursin("initBoard", html)
end

@testset "Pluto Compatibility" begin
    board = Board("test")
    html = sprint(show, MIME("text/html"), board)

    # No <style> tags (Pluto's DOMPurify strips them)
    @test !occursin("<style>", html)

    # Uses CDN <link> for CSS instead
    @test occursin("<link rel=", html)

    # Inline styles on div via style= attribute
    @test occursin("style=", html)

    # Unique IDs per call (same as Unique Display IDs test)
    html2 = sprint(show, MIME("text/html"), board)
    id1 = match(r"id=\"(jxg_[a-zA-Z0-9]+)\"", html)[1]
    id2 = match(r"id=\"(jxg_[a-zA-Z0-9]+)\"", html2)[1]
    @test id1 != id2
end
