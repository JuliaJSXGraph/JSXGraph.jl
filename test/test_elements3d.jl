@testset "3D Elements" begin
    @testset "View3D positional construction" begin
        v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-5, 5]])
        @test v isa View3D
        @test v.type_name == "view3d"
        @test length(v.elements) == 0
        @test length(v.parents) == 3
        @test v.parents[1] == [-6, -3]
        @test v.parents[2] == [8, 8]
        @test v.parents[3] == [[-5, 5], [-5, 5], [-5, 5]]
    end

    @testset "View3D keyword construction" begin
        v = view3d(xlim=(-3, 3), ylim=(-3, 3), zlim=(-3, 3))
        @test v isa View3D
        @test v.parents[3] == [[-3, 3], [-3, 3], [-3, 3]]
    end

    @testset "View3D default construction" begin
        v = view3d()
        @test v isa View3D
        @test v.parents[1] == [-6, -3]
        @test v.parents[2] == [8, 8]
        @test v.parents[3] == [[-5, 5], [-5, 5], [-5, 5]]
    end

    @testset "point3d" begin
        p = point3d(1, 2, 3)
        @test p isa JSXElement
        @test p.type_name == "point3d"
        @test p.parents == Any[1, 2, 3]
    end

    @testset "point3d with attributes" begin
        p = point3d(1, 2, 3; size=5, color="red")
        @test p.type_name == "point3d"
        @test p.attributes["size"] == 5
    end

    @testset "line3d" begin
        p1 = point3d(0, 0, 0)
        p2 = point3d(1, 1, 1)
        l = line3d(p1, p2)
        @test l isa JSXElement
        @test l.type_name == "line3d"
        @test length(l.parents) == 2
    end

    @testset "curve3d" begin
        c = curve3d("Math.cos(t)", "Math.sin(t)", "t/(2*Math.PI)", [-6.28, 6.28])
        @test c isa JSXElement
        @test c.type_name == "curve3d"
        @test length(c.parents) == 4
        @test c.parents[1] isa JSFunction
        @test c.parents[4] == [-6.28, 6.28]
    end

    @testset "curve3d uses t parameter" begin
        c = curve3d("Math.cos(t)", "Math.sin(t)", "t", [0, 6.28])
        @test contains(c.parents[1].code, "function(t)")
        @test contains(c.parents[1].code, "Math.cos(t)")
        @test contains(c.parents[2].code, "function(t)")
        @test contains(c.parents[3].code, "function(t)")
    end

    @testset "functiongraph3d" begin
        fg = functiongraph3d("Math.sin(x)*Math.cos(y)")
        @test fg isa JSXElement
        @test fg.type_name == "functiongraph3d"
        @test length(fg.parents) == 1
        @test fg.parents[1] isa JSFunction
    end

    @testset "functiongraph3d with ranges" begin
        fg = functiongraph3d("x*y"; xlim=(-3, 3), ylim=(-3, 3))
        @test fg.type_name == "functiongraph3d"
        @test length(fg.parents) == 3
        @test fg.parents[2] == [-3, 3]
        @test fg.parents[3] == [-3, 3]
    end

    @testset "parametricsurface3d" begin
        ps = parametricsurface3d(
            "u*Math.cos(v)", "u*Math.sin(v)", "v",
            [0, 2], [0, 6.28],
        )
        @test ps isa JSXElement
        @test ps.type_name == "parametricsurface3d"
        @test length(ps.parents) == 5
        @test ps.parents[1] isa JSFunction
        @test ps.parents[4] == [0, 2]
        @test ps.parents[5] == [0, 6.28]
    end

    @testset "parametricsurface3d uses u,v parameters" begin
        ps = parametricsurface3d(
            "Math.sin(u)*Math.cos(v)",
            "Math.sin(u)*Math.sin(v)",
            "Math.cos(u)",
            [0, 3.14], [0, 6.28],
        )
        @test contains(ps.parents[1].code, "function(u,v)")
        @test contains(ps.parents[1].code, "Math.sin(u)*Math.cos(v)")
        @test contains(ps.parents[2].code, "function(u,v)")
        @test contains(ps.parents[3].code, "function(u,v)")
    end

    @testset "View3D push!" begin
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5))
        push!(v, point3d(1, 2, 3))
        push!(v, point3d(4, 5, 6))
        @test length(v.elements) == 2
        @test v.elements[1].type_name == "point3d"
        @test v.elements[2].type_name == "point3d"
    end

    @testset "View3D multi push!" begin
        v = view3d()
        p1 = point3d(0, 0, 0)
        p2 = point3d(1, 1, 1)
        push!(v, p1, p2)
        @test length(v.elements) == 2
    end

    @testset "View3D do-block" begin
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            push!(v, point3d(1, 2, 3))
            push!(v, functiongraph3d("Math.sin(x)*Math.cos(y)"))
        end
        @test v isa View3D
        @test length(v.elements) == 2
        @test v.elements[1].type_name == "point3d"
        @test v.elements[2].type_name == "functiongraph3d"
    end

    @testset "View3D do-block positional" begin
        v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-5, 5]]) do v
            push!(v, point3d(0, 0, 0))
        end
        @test v isa View3D
        @test length(v.elements) == 1
    end

    @testset "Board with View3D" begin
        b = Board("test3d"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            push!(v, point3d(1, 2, 3; size=5))
        end
        push!(b, v)
        @test length(b.elements) == 1
        @test b.elements[1] isa View3D
    end

    @testset "Board with View3D HTML rendering" begin
        b = Board("test3d_render"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            push!(v, point3d(1, 2, 3; size=5))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('view3d'")
        @test contains(html, "create('point3d'")
    end

    @testset "Board with View3D cross-references" begin
        b = Board("test3d_xref"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            p1 = point3d(0, 0, 0; name="A")
            p2 = point3d(1, 1, 1; name="B")
            push!(v, p1)
            push!(v, p2)
            push!(v, line3d(p1, p2))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('view3d'")
        @test contains(html, "create('point3d'")
        @test contains(html, "create('line3d'")
        # line3d should reference the point3d variables
        @test contains(html, "el_001_001")
        @test contains(html, "el_001_002")
    end

    @testset "View3D with functiongraph3d rendering" begin
        b = Board("test3d_surface"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            push!(v, functiongraph3d("Math.sin(x)*Math.cos(y)"))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('functiongraph3d'")
        @test contains(html, "Math.sin(x)*Math.cos(y)")
    end

    @testset "View3D with curve3d rendering" begin
        b = Board("test3d_curve"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            push!(v, curve3d("Math.cos(t)", "Math.sin(t)", "t", [-6.28, 6.28]))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('curve3d'")
    end

    @testset "View3D with parametricsurface3d rendering" begin
        b = Board("test3d_parsurf"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            push!(v, parametricsurface3d(
                "Math.sin(u)*Math.cos(v)",
                "Math.sin(u)*Math.sin(v)",
                "Math.cos(u)",
                [0, 3.14], [0, 6.28],
            ))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('parametricsurface3d'")
    end
end
