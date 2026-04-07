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

    @testset "vectorfield3d" begin
        vf = vectorfield3d(
            "Math.cos(y)", "Math.sin(x)", "z",
            [-2, 5, 2], [-2, 5, 2], [-2, 5, 2],
        )
        @test vf isa JSXElement
        @test vf.type_name == "vectorfield3d"
        @test length(vf.parents) == 4
        @test vf.parents[1] isa AbstractVector
        @test length(vf.parents[1]) == 3
        @test all(f -> f isa JSFunction, vf.parents[1])
        @test vf.parents[2] == [-2, 5, 2]
        @test vf.parents[3] == [-2, 5, 2]
        @test vf.parents[4] == [-2, 5, 2]
    end

    @testset "vectorfield3d uses x,y,z parameters" begin
        vf = vectorfield3d(
            "Math.cos(y)", "Math.sin(x)", "z",
            [-2, 5, 2], [-2, 5, 2], [-2, 5, 2],
        )
        @test contains(vf.parents[1][1].code, "function(x,y,z)")
        @test contains(vf.parents[1][1].code, "Math.cos(y)")
        @test contains(vf.parents[1][2].code, "function(x,y,z)")
        @test contains(vf.parents[1][2].code, "Math.sin(x)")
        @test contains(vf.parents[1][3].code, "function(x,y,z)")
    end

    @testset "View3D with vectorfield3d rendering" begin
        b = Board("test3d_vf"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-3, 3), ylim=(-3, 3), zlim=(-3, 3)) do v
            push!(v, vectorfield3d(
                "Math.cos(y)", "Math.sin(x)", "z",
                [-2, 5, 2], [-2, 5, 2], [-2, 5, 2];
                strokeColor="red",
            ))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('vectorfield3d'")
        @test contains(html, "Math.cos(y)")
        @test contains(html, "\"strokeColor\":\"red\"")
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

    @testset "sphere3d with radius" begin
        c = point3d(0, 0, 0)
        s = sphere3d(c, 2.0)
        @test s isa JSXElement
        @test s.type_name == "sphere3d"
        @test length(s.parents) == 2
        @test s.parents[2] == 2.0
    end

    @testset "sphere3d with point on surface" begin
        c = point3d(0, 0, 0)
        p = point3d(1, 1, 1)
        s = sphere3d(c, p)
        @test s.type_name == "sphere3d"
        @test s.parents[2] isa JSXElement
    end

    @testset "sphere3d rendering" begin
        b = Board("test3d_sphere"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            c = point3d(0, 0, 0)
            push!(v, c)
            push!(v, sphere3d(c, 2.0; fillColor="blue", fillOpacity=0.3))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('sphere3d'")
    end

    @testset "circle3d" begin
        c = point3d(0, 0, 0)
        circ = circle3d(c, [0, 0, 0, 1], 2.0)
        @test circ isa JSXElement
        @test circ.type_name == "circle3d"
        @test length(circ.parents) == 3
        @test circ.parents[2] == [0, 0, 0, 1]
        @test circ.parents[3] == 2.0
    end

    @testset "circle3d rendering" begin
        b = Board("test3d_circle"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            c = point3d(0, 0, 0)
            push!(v, c)
            push!(v, circle3d(c, [0, 0, 0, 1], 2.0; strokeColor="red"))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('circle3d'")
    end

    @testset "polygon3d" begin
        p1 = point3d(0, 0, 0)
        p2 = point3d(1, 0, 0)
        p3 = point3d(1, 1, 0)
        poly = polygon3d(p1, p2, p3)
        @test poly isa JSXElement
        @test poly.type_name == "polygon3d"
        @test length(poly.parents) == 3
    end

    @testset "polygon3d with 4 vertices" begin
        p1 = point3d(0, 0, 0)
        p2 = point3d(1, 0, 0)
        p3 = point3d(1, 1, 0)
        p4 = point3d(0, 1, 0)
        poly = polygon3d(p1, p2, p3, p4)
        @test length(poly.parents) == 4
    end

    @testset "polygon3d rendering" begin
        b = Board("test3d_polygon"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            p1 = point3d(0, 0, 0)
            p2 = point3d(1, 0, 0)
            p3 = point3d(1, 1, 0)
            push!(v, p1, p2, p3)
            push!(v, polygon3d(p1, p2, p3; fillColor="yellow"))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('polygon3d'")
    end

    @testset "plane3d with directions" begin
        p = point3d(0, 0, 0)
        pl = plane3d(p, [1, 0, 0], [0, 1, 0])
        @test pl isa JSXElement
        @test pl.type_name == "plane3d"
        @test length(pl.parents) == 3
    end

    @testset "plane3d with ranges" begin
        p = point3d(0, 0, 0)
        pl = plane3d(p, [1, 0, 0], [0, 1, 0]; range_u=(-2, 2), range_v=(-2, 2))
        @test pl.type_name == "plane3d"
        @test length(pl.parents) == 5
        @test pl.parents[4] == [-2, 2]
        @test pl.parents[5] == [-2, 2]
    end

    @testset "plane3d three points" begin
        p1 = point3d(0, 0, 0)
        p2 = point3d(1, 0, 0)
        p3 = point3d(0, 1, 0)
        pl = plane3d(p1, p2, p3)
        @test pl isa JSXElement
        @test pl.type_name == "plane3d"
        @test length(pl.parents) == 3
        @test pl.attributes["threePoints"] == true
    end

    @testset "plane3d rendering" begin
        b = Board("test3d_plane"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            p = point3d(0, 0, 0)
            push!(v, p)
            push!(v, plane3d(p, [1, 0, 0], [0, 1, 0]; range_u=(-2, 2), range_v=(-2, 2),
                fillColor="blue", fillOpacity=0.2))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('plane3d'")
    end

    @testset "intersectionline3d" begin
        p = point3d(0, 0, 0)
        pl1 = plane3d(p, [1, 0, 0], [0, 1, 0]; range_u=(-3, 3), range_v=(-3, 3))
        pl2 = plane3d(p, [1, 0, 1], [0, 1, 0]; range_u=(-3, 3), range_v=(-3, 3))
        il = intersectionline3d(pl1, pl2)
        @test il isa JSXElement
        @test il.type_name == "intersectionline3d"
        @test length(il.parents) == 2
    end

    @testset "intersectionline3d rendering" begin
        b = Board("test3d_intline"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            p = point3d(0, 0, 0)
            push!(v, p)
            pl1 = plane3d(p, [1, 0, 0], [0, 1, 0]; range_u=(-3, 3), range_v=(-3, 3))
            pl2 = plane3d(p, [1, 0, 1], [0, 1, 0]; range_u=(-3, 3), range_v=(-3, 3))
            push!(v, pl1)
            push!(v, pl2)
            push!(v, intersectionline3d(pl1, pl2; strokeColor="red"))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('intersectionline3d'")
    end

    @testset "intersectioncircle3d" begin
        c1 = point3d(-1, 0, 0)
        c2 = point3d(1, 0, 0)
        s1 = sphere3d(c1, 2.0)
        s2 = sphere3d(c2, 2.0)
        ic = intersectioncircle3d(s1, s2)
        @test ic isa JSXElement
        @test ic.type_name == "intersectioncircle3d"
        @test length(ic.parents) == 2
    end

    @testset "intersectioncircle3d rendering" begin
        b = Board("test3d_intcirc"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            c1 = point3d(-1, 0, 0)
            c2 = point3d(1, 0, 0)
            push!(v, c1, c2)
            s1 = sphere3d(c1, 2.0)
            s2 = sphere3d(c2, 2.0)
            push!(v, s1, s2)
            push!(v, intersectioncircle3d(s1, s2; strokeColor="purple"))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('intersectioncircle3d'")
    end

    @testset "text3d" begin
        t = text3d(1, 2, 3, "Hello")
        @test t isa JSXElement
        @test t.type_name == "text3d"
        @test length(t.parents) == 4
        @test t.parents[4] == "Hello"
    end

    @testset "text3d with attributes" begin
        t = text3d(0, 0, 0, "Label"; fontSize=20)
        @test t.attributes["fontSize"] == 20
    end

    @testset "text3d rendering" begin
        b = Board("test3d_text"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            push!(v, text3d(1, 2, 3, "Hello 3D"; fontSize=20))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('text3d'")
        @test contains(html, "Hello 3D")
    end

    @testset "mesh3d" begin
        m = mesh3d([0, 0, 0], [1, 0, 0], [0, 1, 0], [-3, 3], [-3, 3])
        @test m isa JSXElement
        @test m.type_name == "mesh3d"
        @test length(m.parents) == 5
        @test m.parents[1] == [0, 0, 0]
        @test m.parents[4] == [-3, 3]
    end

    @testset "mesh3d with attributes" begin
        m = mesh3d([0, 0, 0], [1, 0, 0], [0, 1, 0], [-2, 2], [-2, 2];
            stepWidthU=0.5, stepWidthV=0.5)
        @test m.attributes["stepWidthU"] == 0.5
    end

    @testset "mesh3d rendering" begin
        b = Board("test3d_mesh"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            push!(v, mesh3d([0, 0, 0], [1, 0, 0], [0, 1, 0], [-3, 3], [-3, 3];
                stepWidthU=1, stepWidthV=1))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('mesh3d'")
    end

    @testset "polyhedron3d tetrahedron" begin
        verts = [[0, 0, 0], [2, 0, 0], [1, 2, 0], [1, 1, 2]]
        faces = [[0, 1, 2], [0, 1, 3], [1, 2, 3], [0, 2, 3]]
        p = polyhedron3d(verts, faces)
        @test p isa JSXElement
        @test p.type_name == "polyhedron3d"
        @test length(p.parents) == 2
        @test p.parents[1] == verts
        @test p.parents[2] == faces
    end

    @testset "polyhedron3d with attributes" begin
        verts = [[0, 0, 0], [1, 0, 0], [0, 1, 0], [0, 0, 1]]
        faces = [[0, 1, 2], [0, 1, 3], [1, 2, 3], [0, 2, 3]]
        p = polyhedron3d(verts, faces; fillOpacity=0.8)
        @test p.attributes["fillOpacity"] == 0.8
    end

    @testset "polyhedron3d rendering" begin
        b = Board("test3d_polyhedron"; xlim=(-8, 8), ylim=(-8, 8))
        v = view3d(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5, 5)) do v
            verts = [[0, 0, 0], [3, 0, 0], [1.5, 3, 0], [1.5, 1, 3]]
            faces = [[0, 1, 2], [0, 1, 3], [1, 2, 3], [0, 2, 3]]
            push!(v, polyhedron3d(verts, faces; fillOpacity=0.7))
        end
        push!(b, v)
        html = html_string(b)
        @test contains(html, "create('polyhedron3d'")
    end
end
