@testset "Julia to JS Conversion" begin
    # Basic arithmetic
    @test julia_to_js(:(x + 1)) == "x + 1"
    @test julia_to_js(:(x - 1)) == "x - 1"
    @test julia_to_js(:(x * 2)) == "x * 2"
    @test julia_to_js(:(x / 2)) == "x / 2"

    # Math functions → Math.*
    @test julia_to_js(:(sin(x))) == "Math.sin(x)"
    @test julia_to_js(:(cos(x))) == "Math.cos(x)"
    @test julia_to_js(:(exp(x))) == "Math.exp(x)"
    @test julia_to_js(:(sqrt(x))) == "Math.sqrt(x)"
    @test julia_to_js(:(log(x))) == "Math.log(x)"
    @test julia_to_js(:(abs(x))) == "Math.abs(x)"

    # Power → Math.pow
    @test julia_to_js(:(x^2)) == "Math.pow(x, 2)"

    # Constants
    @test julia_to_js(:pi) == "Math.PI"
    @test julia_to_js(:π) == "Math.PI"
    @test julia_to_js(:ℯ) == "Math.E"

    # Lambda
    @test julia_to_js(:(x -> sin(x) + x^2)) ==
        "function(x){return Math.sin(x) + Math.pow(x, 2);}"

    # Nested calls
    @test julia_to_js(:(cos(x) * exp(-x))) == "Math.cos(x) * Math.exp(-x)"

    # Unary minus
    @test julia_to_js(:(-x)) == "-x"

    # Numbers
    @test julia_to_js(:(3.14)) == "3.14"
    @test julia_to_js(:(42)) == "42"

    # Function objects
    @test julia_to_js(sin) == "function(x){return Math.sin(x);}"
    @test julia_to_js(cos) == "function(x){return Math.cos(x);}"
end

@testset "@jsf Macro" begin
    # Lambda → JSFunction
    f = @jsf x -> sin(x)
    @test f isa JSFunction
    @test f.code == "function(x){return Math.sin(x);}"

    # Complex expression
    f2 = @jsf x -> sin(x) + x^2
    @test f2.code == "function(x){return Math.sin(x) + Math.pow(x, 2);}"

    # Multi-argument lambda
    f3 = @jsf (x, y) -> x^2 + y^2
    @test f3.code == "function(x, y){return Math.pow(x, 2) + Math.pow(y, 2);}"

    # Constants
    f4 = @jsf x -> x * π
    @test occursin("Math.PI", f4.code)

    # Nested math functions
    f5 = @jsf x -> cos(x) * exp(-x)
    @test f5.code == "function(x){return Math.cos(x) * Math.exp(-x);}"

    # Use with functiongraph
    fg = functiongraph(@jsf x -> x^2)
    @test fg isa JSXElement
    @test fg.parents[1] isa JSFunction
    @test occursin("Math.pow", fg.parents[1].code)

    # Simple expression (not lambda)
    f6 = @jsf sin(x) + cos(x)
    @test f6 isa JSFunction
    @test f6.code == "Math.sin(x) + Math.cos(x)"
end

@testset "@jsf Unsupported Constructs" begin
    # try/catch
    @test_throws ArgumentError @macroexpand @jsf try
        sin(x)
    catch
        0
    end

    # for loop
    @test_throws ArgumentError @macroexpand @jsf for i in 1:10
        i
    end

    # while loop
    @test_throws ArgumentError @macroexpand @jsf while true
        0
    end

    # comprehension
    @test_throws ArgumentError @macroexpand @jsf [x^2 for x in 1:10]

    # Multi-statement body
    @test_throws ArgumentError @macroexpand @jsf x -> begin
        a = sin(x)
        a + 1
    end
end

@testset "Named JSFunction (REQ-GEO-012)" begin
    # named_jsf creates a named JSFunction
    f = @jsf x -> x^2
    nf = named_jsf(:square, f)
    @test nf isa JSFunction
    @test nf.name == "square"
    @test nf.code == f.code
    @test isempty(nf.deps)

    # with_deps attaches dependencies
    g = with_deps(@jsf(x -> square(x) + 1), nf)
    @test g isa JSFunction
    @test length(g.deps) == 1
    @test g.deps[1].name == "square"

    # @named_jsf macro — single parameter
    @named_jsf cube(x) = x^3
    @test cube isa JSFunction
    @test cube.name == "cube"
    @test occursin("Math.pow(x, 3)", cube.code)
    @test isempty(cube.deps)

    # @named_jsf macro — multiple parameters
    @named_jsf avg(a, b) = (a + b) / 2
    @test avg isa JSFunction
    @test avg.name == "avg"
    @test occursin("a + b", avg.code)

    # @named_jsf validation — reject unsupported constructs
    @test_throws ArgumentError @macroexpand @named_jsf bad(x) = begin
        a = sin(x)
        a + 1
    end

    # @named_jsf validation — reject wrong syntax
    @test_throws ArgumentError @macroexpand @named_jsf 42
end

@testset "Transitive Dependency Rendering (REQ-GEO-012)" begin
    # Single dependency
    @named_jsf helper(x) = x^2
    main = with_deps(@jsf(x -> helper(x) + 1), helper)
    fg = functiongraph(main)
    b = Board("dep1") + fg
    html = html_string(b; asset_mode=:cdn)
    @test occursin("function helper(x){return Math.pow(x, 2);}", html)
    @test occursin("helper(x) + 1", html)

    # Transitive: A → B → C
    @named_jsf dep_c(x) = x + 1
    dep_b = with_deps(
        JSFunction("function(x){return dep_c(x) * 2;}", "dep_b", JSFunction[]),
        dep_c,
    )
    dep_a = with_deps(@jsf(x -> dep_b(x) + dep_c(x)), dep_b, dep_c)
    fg2 = functiongraph(dep_a)
    b2 = Board("dep2") + fg2
    html2 = html_string(b2; asset_mode=:cdn)
    # dep_c must appear before dep_b (topological order)
    pos_c = findfirst("function dep_c(", html2)
    pos_b = findfirst("function dep_b(", html2)
    @test pos_c !== nothing
    @test pos_b !== nothing
    @test pos_c.start < pos_b.start
    # Both dep_c and dep_b appear in output
    @test occursin("function dep_c(x){return x + 1;}", html2)
    @test occursin("function dep_b(x){return dep_c(x) * 2;}", html2)

    # No duplicates: dep shared by two elements
    @named_jsf shared(x) = sin(x)
    f1 = with_deps(@jsf(x -> shared(x) + 1), shared)
    f2 = with_deps(@jsf(x -> shared(x) * 2), shared)
    b3 = Board("dep3") + functiongraph(f1) + functiongraph(f2)
    html3 = html_string(b3; asset_mode=:cdn)
    # shared should appear exactly once
    @test count("function shared(x)", html3) == 1

    # No deps — nothing extra emitted
    plain = @jsf x -> sin(x)
    b4 = Board("nodep") + functiongraph(plain)
    html4 = html_string(b4; asset_mode=:cdn)
    @test !occursin(r"^function [a-zA-Z]", html4)  # no named function declarations

    # Backward compatibility: JSFunction(code) still works
    jsf_old = JSFunction("function(x){return x;}")
    @test jsf_old.code == "function(x){return x;}"
    @test jsf_old.name == ""
    @test isempty(jsf_old.deps)
end
