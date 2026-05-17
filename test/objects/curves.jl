@testset "FunctionGraph" begin
    @jsf foo(t) = t^2+2t+1
    fg = functiongraph(foo, a=1, b=5, strokeColor="blue")
    @test fg isa J.FunctionGraph
    @test fg.f.name == :foo
    @test fg.a == 1
    @test fg.b == 5
    @test fg.opts[:strokeColor] == "blue"

    # str
    brd = board("brd")
    sfg = J.str(fg, brd)
    @test occursin("function foo(t){return (Math.pow(t,2)+(2*t)+1)};", sfg)
    @test occursin(
        """brd.create('functiongraph', [function(t){return foo(t);}, 1, 5], {"strokeColor":"blue"});""",
        sfg,
    )
end

@testset "ParamCurve" begin
    @jsf f1(t) = t - sin(t)
    @jsf f2(t) = 1 - cos(t)
    pc = parametriccurve(f1, f2; a=0, b=10, dash=2)
    @test pc isa J.Curve
    @test pc.x isa J.JSFun
    @test pc.y isa J.JSFun
    @test pc.a isa Real
    @test pc.b isa Real
    @test pc.opts[:dash] == 2
    pc2 = pcurve(f1, f2)
    @test isnothing(pc2.opts)
    @test pc2.a == -10
    @test pc2.b == 10

    # str
    b = board("b")
    spc = J.str(pc, b)
    @test occursin(
        "function f1(t){return (t-sin(t))};function f2(t){return (1-cos(t))};", spc
    )
    @test occursin(
        """b.create('curve', [function(t){return f1(t);}, function(t){return f2(t);}, 0, 10], {"dash":2});""",
        spc,
    )
end

@testset "DataPlot" begin
    x = [1, 2, 3]
    y = [1, 2, 3]
    dp = dataplot(x, y)
    @test dp.x == [1, 2, 3]
    @test dp.y == [1, 2, 3]
    @test isnothing(dp.opts)
    x = [1, 2]
    @test_throws DimensionMismatch dataplot(x, y)

    # str
    b = board("b")
    sdp = J.str(dp, b)
    @test sdp == "b.create('curve', [[1,2,3], [1,2,3]], {});"
end

@testset "plot" begin
    # plot(fun opts...)
    @jsf f1(t) = t - sin(t)
    p = plot(f1; strokeColor="blue")
    @test p isa J.FunctionGraph
    sp = J.str(p, board("b", xlim=[-5, 5]))
    @test occursin("function f1(t){return (t-sin(t))};", sp)
    @test occursin(
        """b.create('functiongraph', [function(t){return f1(t);}, -5, 5], {"strokeColor":"blue"});""",
        sp,
    )

    # plot fun, fun
    @jsf f2(t) = cos(t)
    p = plot(f1, f2; a=0, b=10)
    @test p isa J.ParametricCurve
    @test p.x == f1
    @test p.y == f2
    @test p.a == 0
    @test p.b == 10

    # plot arr, fun
    p = plot(range(0, 1, length=10), f2)
    @test p isa J.DataPlot
    @test p.x == range(0, 1, length=10)
    @test p.y == f2
end
