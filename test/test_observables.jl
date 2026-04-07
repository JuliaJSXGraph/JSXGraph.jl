using Observables

@testset "Observables.jl Integration" begin
    @testset "Observable as parent value" begin
        x_obs = Observable(1.0)
        y_obs = Observable(2.0)
        p = point(x_obs, y_obs; name="P")
        b = Board("obs_test"; xlim=(-5, 5), ylim=(-5, 5))
        push!(b, p)
        html = html_string(b)
        @test contains(html, "1.0")
        @test contains(html, "2.0")
    end

    @testset "Observable parent updates before render" begin
        x_obs = Observable(0.0)
        p = point(x_obs, 3.0; name="Q")
        b = Board("obs_test2"; xlim=(-5, 5), ylim=(-5, 5))
        push!(b, p)
        # Update observable before rendering
        x_obs[] = 4.5
        html = html_string(b)
        @test contains(html, "4.5")
    end

    @testset "Observable as attribute value" begin
        color_obs = Observable("red")
        p = point(1, 2; strokeColor=color_obs)
        b = Board("obs_attr"; xlim=(-5, 5), ylim=(-5, 5))
        push!(b, p)
        html = html_string(b)
        @test contains(html, "\"strokeColor\":\"red\"")
    end

    @testset "Observable attribute updates before render" begin
        color_obs = Observable("blue")
        p = point(1, 2; strokeColor=color_obs)
        b = Board("obs_attr2"; xlim=(-5, 5), ylim=(-5, 5))
        push!(b, p)
        color_obs[] = "green"
        html = html_string(b)
        @test contains(html, "\"strokeColor\":\"green\"")
    end

    @testset "resolve_value unwraps Observable" begin
        obs = Observable(42)
        @test JSXGraph.resolve_value(obs) == 42
    end

    @testset "resolve_value passes through non-Observable" begin
        @test JSXGraph.resolve_value(42) == 42
        @test JSXGraph.resolve_value("hello") == "hello"
    end
end
