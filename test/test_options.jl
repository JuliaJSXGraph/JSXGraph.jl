@testset "Options Mapping" begin
    # JS options output
    js_str = JSXGraph.board_options_to_js(
        Dict{String,Any}("axis" => true, "boundingbox" => [-5, 5, 5, -5])
    )
    @test occursin("\"axis\"", js_str)
    @test occursin("true", js_str)
    @test occursin("boundingbox", js_str)

    # CSS-only options should NOT be in JS output
    js_str2 = JSXGraph.board_options_to_js(
        Dict{String,Any}(
            "axis" => true, "width" => 500, "height" => 500, "background" => "#ffffff"
        ),
    )
    @test !occursin("\"width\"", js_str2)
    @test !occursin("\"height\"", js_str2)
    @test !occursin("\"background\"", js_str2)

    # Unknown keys pass through to JS
    js_str3 = JSXGraph.board_options_to_js(Dict{String,Any}("keepAspectRatio" => true))
    @test occursin("keepAspectRatio", js_str3)
    @test occursin("true", js_str3)

    # Extract CSS options
    css = JSXGraph.extract_css_options(
        Dict{String,Any}(
            "width" => 600, "height" => 400, "background" => "#ccc", "axis" => true
        ),
    )
    @test css["width"] == 600
    @test css["height"] == 400
    @test css["background"] == "#ccc"
    @test !haskey(css, "axis")
end
