@testset "board" begin
    brd = board()
    @test startswith(brd.name, "brd_")
    @test brd isa J.Board
    @test brd.xlim == [-10.0, 10.0]
    @test brd.ylim == [-10.0, 10.0]
    @test !brd.axis
    @test !brd.showcopyright
    @test !brd.shownavigation

    brd = board("foo", xlim=[-2, 2], ylim=[3, 4], axis=true)
    @test brd.xlim == [-2, 2]
    @test brd.ylim == [3, 4]
    @test brd.axis

    @test_throws AssertionError board(boundingbox=[1, 2])

    # --- Get options
    o = J.get_opts(brd)
    @test o.boundingbox == [-2, 4, 2, 3]
    @test o.axis
    @test !o.shownavigation
end

@testset "board-add" begin
    brd = board()
    s1 = slider("a", [[1, -1], [5, -1], [0, 1.5, 3]])
    s2 = slider("b", [[1, -1], [5, -1], [0, 1.5, 3]])
    brd((s1, s2))
    @test length(brd.objects) == 2
    @test brd.objects[1].name == "a"
    @test brd.objects[2].name == "b"

    brd = board()
    brd ++ s1
    @test length(brd.objects) == 1
    @test brd.objects[1].name == "a"

    brd = board()
    brd ++ (s1, s2)
    @test length(brd.objects) == 2
end

@testset "board-str" begin
    brd = board("brd")
    s1 = slider("a", [[1, -1], [5, -1], [0, 1.5, 3]])
    brd ++ s1

    s = J.str(brd)
    @test occursin("function val(x)", s)
    @test occursin(".initBoard(\"brd\",", s)
    @test occursin(".create('slider',", s)

    # -- save
    tmp = tempname()
    J.save(brd, tmp)
    s = read(tmp * ".js", String)
    @test s == J.str(brd)

    # -- standalone
    h = J.standalone(brd, full=true)
    @test occursin(s, h)
end
