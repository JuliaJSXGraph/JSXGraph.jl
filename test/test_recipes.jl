using JSXGraphRecipesBase

# --- Test types for recipes ---

struct RecipeTriangle
    A::Tuple{Float64, Float64}
    B::Tuple{Float64, Float64}
    C::Tuple{Float64, Float64}
end

struct RecipeCircle2D
    cx::Float64
    cy::Float64
    r::Float64
end

struct NoRecipeObj end

# --- Define recipes ---

@jsxrecipe function f(t::RecipeTriangle; color="blue")
    p1 = ElementSpec(:point, t.A[1], t.A[2]; name="A")
    p2 = ElementSpec(:point, t.B[1], t.B[2]; name="B")
    p3 = ElementSpec(:point, t.C[1], t.C[2]; name="C")
    [p1, p2, p3, ElementSpec(:polygon, p1, p2, p3; strokeColor=color)]
end

@jsxrecipe function f(c::RecipeCircle2D; color="black")
    center = ElementSpec(:point, c.cx, c.cy; visible=false)
    [center, ElementSpec(:circle, center, c.r; strokeColor=color)]
end

@testset "Recipes" begin
    @testset "realize_specs - simple" begin
        specs = [
            ElementSpec(:point, 1, 2; name="P"),
            ElementSpec(:point, 3, 4; name="Q"),
        ]
        elems = realize_specs(specs)
        @test length(elems) == 2
        @test elems[1] isa JSXElement
        @test elems[1].type_name == "point"
        @test elems[2].type_name == "point"
    end

    @testset "realize_specs - with dependencies" begin
        p1 = ElementSpec(:point, 0, 0)
        p2 = ElementSpec(:point, 1, 1)
        l = ElementSpec(:line, p1, p2; strokeColor="red")
        specs = [p1, p2, l]
        elems = realize_specs(specs)
        @test length(elems) == 3
        @test elems[3].type_name == "line"
        # The line's parents should be the realized JSXElement objects
        @test elems[3].parents[1] === elems[1]
        @test elems[3].parents[2] === elems[2]
    end

    @testset "realize_specs - unresolved dependency" begin
        p1 = ElementSpec(:point, 0, 0)
        p2 = ElementSpec(:point, 1, 1)
        # p2 is referenced but not included in specs before line
        l = ElementSpec(:line, p1, p2; strokeColor="red")
        @test_throws ErrorException realize_specs([p1, l])
    end

    @testset "plot! with recipe" begin
        b = Board("")
        tri = RecipeTriangle((0.0, 0.0), (3.0, 0.0), (1.5, 2.5))
        plot!(b, tri)
        @test length(b.elements) == 4  # 3 points + 1 polygon
        @test b.elements[1].type_name == "point"
        @test b.elements[2].type_name == "point"
        @test b.elements[3].type_name == "point"
        @test b.elements[4].type_name == "polygon"
    end

    @testset "plot! with kwargs" begin
        b = Board("")
        tri = RecipeTriangle((0.0, 0.0), (3.0, 0.0), (1.5, 2.5))
        plot!(b, tri; color="red")
        # The polygon should have strokeColor="red"
        @test b.elements[4].attributes["strokeColor"] == "red"
    end

    @testset "plot! - no recipe" begin
        b = Board("")
        @test_throws ArgumentError plot!(b, NoRecipeObj())
        @test_throws ArgumentError plot!(b, 42)
    end

    @testset "plot(board, obj) - non-mutating" begin
        b = Board(""; xlim=(-5, 5), ylim=(-5, 5))
        circ = RecipeCircle2D(0.0, 0.0, 2.0)
        b2 = plot(b, circ)
        @test length(b.elements) == 0   # original unchanged
        @test length(b2.elements) == 2  # center + circle
        @test b2.elements[1].type_name == "point"
        @test b2.elements[2].type_name == "circle"
    end

    @testset "board + obj via recipe" begin
        b = Board(""; xlim=(-5, 5), ylim=(-5, 5))
        circ = RecipeCircle2D(1.0, 2.0, 3.0)
        b2 = b + circ
        @test length(b.elements) == 0   # original unchanged
        @test length(b2.elements) == 2  # center + circle
    end

    @testset "board + obj - no recipe" begin
        b = Board("")
        @test_throws ArgumentError b + NoRecipeObj()
    end

    @testset "has_recipe re-exported" begin
        @test has_recipe(RecipeTriangle)
        @test has_recipe(RecipeCircle2D)
        @test !has_recipe(NoRecipeObj)
    end

    @testset "HTML generation with recipe elements" begin
        b = Board(""; xlim=(-5, 5), ylim=(-5, 5))
        tri = RecipeTriangle((0.0, 0.0), (3.0, 0.0), (1.5, 2.5))
        plot!(b, tri)
        html = html_string(b)
        @test contains(html, "create('point'")
        @test contains(html, "create('polygon'")
    end

    @testset "do-block with recipes" begin
        b = board(xlim=(-5, 5), ylim=(-5, 5)) do b
            plot!(b, RecipeTriangle((0.0, 0.0), (3.0, 0.0), (1.5, 2.5)))
            plot!(b, RecipeCircle2D(0.0, 0.0, 1.0))
        end
        @test length(b.elements) == 6  # 3+1 from triangle + 1+1 from circle
    end

    @testset "alias integration in recipes" begin
        b = Board("")
        # Use alias keywords in recipe that get resolved
        circ = RecipeCircle2D(0.0, 0.0, 1.0)
        plot!(b, circ; color="green")
        @test b.elements[2].attributes["strokeColor"] == "green"
    end
end
