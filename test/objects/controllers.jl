@testset "Slider" begin
    s = slider("a", [0, 0], [3, 0], [0, 1.5, 3])
    @test s.name == "a"
    @test s.vals == [[0, 0], [3, 0], [0, 1.5, 3]]

    @test_throws AssertionError slider("a", [0, 1])
    @test_throws AssertionError slider("a", [[1, 2], [2, 3, 4], [1, 2]])

    # midpoint
    @test val(s) == 1.5

    b = board("brd")
    ss = J.str(s, b)
    @test ss == "var a=brd.create('slider', [[0.0,0.0],[3.0,0.0],[0.0,1.5,3.0]], {});"
end
