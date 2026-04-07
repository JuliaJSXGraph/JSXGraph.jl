@testset "MathJS Integration (REQ-JSF-003)" begin
    # Ensure clean state
    disable_mathjs!()

    @testset "Enable/Disable" begin
        @test !mathjs_enabled()

        enable_mathjs!()
        @test mathjs_enabled()

        disable_mathjs!()
        @test !mathjs_enabled()
    end

    @testset "MathJS Functions in julia_to_js" begin
        # Without MathJS enabled, gamma is a generic function call
        disable_mathjs!()
        @test julia_to_js(:(gamma(x))) == "gamma(x)"
        @test julia_to_js(:(erf(x))) == "erf(x)"

        # With MathJS enabled, gamma maps to math.gamma
        enable_mathjs!()
        @test julia_to_js(:(gamma(x))) == "math.gamma(x)"
        @test julia_to_js(:(erf(x))) == "math.erf(x)"
        @test julia_to_js(:(factorial(n))) == "math.factorial(n)"
        @test julia_to_js(:(combinations(n, k))) == "math.combinations(n, k)"
        @test julia_to_js(:(gcd(a, b))) == "math.gcd(a, b)"
        @test julia_to_js(:(cbrt(x))) == "math.cbrt(x)"
        @test julia_to_js(:(sec(x))) == "math.sec(x)"
        @test julia_to_js(:(csc(x))) == "math.csc(x)"
        @test julia_to_js(:(cot(x))) == "math.cot(x)"
        @test julia_to_js(:(asinh(x))) == "math.asinh(x)"
        @test julia_to_js(:(acosh(x))) == "math.acosh(x)"
        @test julia_to_js(:(atanh(x))) == "math.atanh(x)"

        disable_mathjs!()
    end

    @testset "Standard Math.* still works with MathJS enabled" begin
        enable_mathjs!()

        # Standard functions still map to Math.*
        @test julia_to_js(:(sin(x))) == "Math.sin(x)"
        @test julia_to_js(:(cos(x))) == "Math.cos(x)"
        @test julia_to_js(:(exp(x))) == "Math.exp(x)"
        @test julia_to_js(:(sqrt(x))) == "Math.sqrt(x)"
        @test julia_to_js(:(abs(x))) == "Math.abs(x)"

        disable_mathjs!()
    end

    @testset "@jsf with MathJS" begin
        enable_mathjs!()

        f = @jsf x -> gamma(x)
        @test f isa JSFunction
        @test f.code == "function(x){return math.gamma(x);}"

        f2 = @jsf x -> erf(x) + sin(x)
        @test occursin("math.erf(x)", f2.code)
        @test occursin("Math.sin(x)", f2.code)

        f3 = @jsf (n, k) -> combinations(n, k)
        @test f3.code == "function(n, k){return math.combinations(n, k);}"

        disable_mathjs!()
    end

    @testset "HTML includes MathJS CDN when enabled" begin
        enable_mathjs!()

        b = Board("test_mathjs")
        push!(b, functiongraph(@jsf x -> gamma(x)))
        html = html_string(b; asset_mode=:cdn)
        @test occursin("mathjs", html)
        @test occursin(MATHJS_CDN_JS, html)

        disable_mathjs!()

        # Without MathJS, no mathjs CDN script
        b2 = Board("test_no_mathjs")
        push!(b2, functiongraph(@jsf x -> sin(x)))
        html2 = html_string(b2; asset_mode=:cdn)
        @test !occursin(MATHJS_CDN_JS, html2)
    end

    @testset "HTML fragment includes MathJS when enabled" begin
        enable_mathjs!()

        b = Board("test_mathjs_frag")
        push!(b, functiongraph(@jsf x -> erf(x)))
        html = html_string(b; full_page=false, asset_mode=:cdn)
        @test occursin("mathjs", html)

        disable_mathjs!()
    end

    @testset "MathJS version constant" begin
        @test MATHJS_VERSION isa String
        @test !isempty(MATHJS_VERSION)
        @test occursin(MATHJS_VERSION, MATHJS_CDN_JS)
    end

    # Final cleanup
    disable_mathjs!()
end
