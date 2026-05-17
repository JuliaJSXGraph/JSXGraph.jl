@testset "misc" begin
    @test J.val(nothing) == 1
    @test J.val(2) == 1
    @test J.Option{Int} == Union{Nothing,Int}
end

@testset "isdef" begin
    b = board(name="b")
    b ++ @jsf foo(x) = 5x
    b ++ @jsf bar(x) = 7x
    b ++ @jsf foo(x) = 2x

    @jsf foo(x) = 2x
    @jsf bar(x) = 7x

    @test J.isdef(foo, b)
    @test J.isdef(bar, b)

    @jsf foo(x) = 5x

    @test !J.isdef(foo, b)
    @test !J.isdef(bar, nothing)
end
