# 3D Gallery

A collection of 3D examples using JSXGraph's `View3D` viewport.
Each example demonstrates interactive 3D rendering with rotation via trackball.

## Basic 3D Geometry

### 1. Basic 3D Points

```@example gallery3d
using JSXGraph
b = board("points3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-5, 5]]) do v
        push!(v, point3d(1, 2, 3; size=5, name="A", color="red"))
        push!(v, point3d(-2, 1, 4; size=5, name="B", color="blue"))
        push!(v, point3d(3, -1, -2; size=5, name="C", color="green"))
    end
    push!(b, v)
end
b
```

### 2. 3D Line Through Two Points

```@example gallery3d
b = board("line3d_demo", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-5, 5]]) do v
        p1 = point3d(-3, -3, -3; size=4, name="P₁", color="red")
        p2 = point3d(3, 3, 3; size=4, name="P₂", color="blue")
        push!(v, p1)
        push!(v, p2)
        push!(v, line3d(p1, p2; strokeColor="purple", strokeWidth=2))
    end
    push!(b, v)
end
b
```

## Curves

### 3. Helix (Parametric 3D Curve)

```@example gallery3d
b = board("helix3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-5, 5]]) do v
        push!(v, curve3d(
            "Math.cos(t)", "Math.sin(t)", "t/(2*Math.PI)",
            [-2*π, 2*π];
            strokeColor="blue", strokeWidth=2,
        ))
    end
    push!(b, v)
end
b
```

### 4. Lissajous 3D Curve

```@example gallery3d
b = board("lissajous3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-3, 3], [-3, 3], [-3, 3]]) do v
        push!(v, curve3d(
            "2*Math.sin(3*t)", "2*Math.sin(2*t)", "2*Math.sin(5*t)",
            [0, 2*π];
            strokeColor="crimson", strokeWidth=2,
        ))
    end
    push!(b, v)
end
b
```

### 5. Conical Spiral

```@example gallery3d
b = board("spiral3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-1, 5]]) do v
        push!(v, curve3d(
            "t*Math.cos(4*t)/5", "t*Math.sin(4*t)/5", "t/5",
            [0, 5*π];
            strokeColor="darkorange", strokeWidth=2,
        ))
    end
    push!(b, v)
end
b
```

## Surfaces

### 6. Surface Plot — Sine Wave

```@example gallery3d
b = board("sine_surface", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-2, 2]]) do v
        push!(v, functiongraph3d("Math.sin(x)*Math.cos(y)";
            strokeWidth=0.5,
            stepsU=40, stepsV=40,
        ))
    end
    push!(b, v)
end
b
```

### 7. Saddle Surface

```@example gallery3d
b = board("saddle3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-3, 3], [-3, 3], [-5, 5]]) do v
        push!(v, functiongraph3d("x*x - y*y";
            strokeWidth=0.5,
            stepsU=30, stepsV=30,
        ))
    end
    push!(b, v)
end
b
```

### 8. Gaussian Surface

```@example gallery3d
b = board("gaussian3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-0.5, 2]]) do v
        push!(v, functiongraph3d("2*Math.exp(-(x*x + y*y)/2)";
            strokeWidth=0.5,
            stepsU=40, stepsV=40,
        ))
    end
    push!(b, v)
end
b
```

### 9. Ripple Surface

```@example gallery3d
b = board("ripple3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-2, 2]]) do v
        push!(v, functiongraph3d("Math.sin(Math.sqrt(x*x + y*y))";
            strokeWidth=0.5,
            stepsU=50, stepsV=50,
        ))
    end
    push!(b, v)
end
b
```

## Parametric Surfaces

### 10. Sphere

```@example gallery3d
b = board("sphere3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-3, 3], [-3, 3], [-3, 3]]) do v
        push!(v, parametricsurface3d(
            "2*Math.sin(u)*Math.cos(v)",
            "2*Math.sin(u)*Math.sin(v)",
            "2*Math.cos(u)",
            [0, π], [0, 2*π];
            strokeWidth=0.5,
            stepsU=30, stepsV=30,
        ))
    end
    push!(b, v)
end
b
```

### 11. Torus

```@example gallery3d
b = board("torus3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    R = 3  # major radius
    r = 1  # minor radius
    v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-3, 3]]) do v
        push!(v, parametricsurface3d(
            "($R + $r*Math.cos(v))*Math.cos(u)",
            "($R + $r*Math.cos(v))*Math.sin(u)",
            "$r*Math.sin(v)",
            [0, 2*π], [0, 2*π];
            strokeWidth=0.5,
            stepsU=40, stepsV=20,
        ))
    end
    push!(b, v)
end
b
```

### 12. Möbius Strip

```@example gallery3d
b = board("mobius3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-2, 2]]) do v
        push!(v, parametricsurface3d(
            "(2 + u*Math.cos(v/2))*Math.cos(v)",
            "(2 + u*Math.cos(v/2))*Math.sin(v)",
            "u*Math.sin(v/2)",
            [-0.5, 0.5], [0, 2*π];
            strokeWidth=0.5,
            stepsU=10, stepsV=40,
        ))
    end
    push!(b, v)
end
b
```

### 13. Klein Bottle (Immersion)

```@example gallery3d
b = board("klein3d", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-5, 5]]) do v
        push!(v, parametricsurface3d(
            "(2 + Math.cos(u/2)*Math.sin(v) - Math.sin(u/2)*Math.sin(2*v))*Math.cos(u)",
            "(2 + Math.cos(u/2)*Math.sin(v) - Math.sin(u/2)*Math.sin(2*v))*Math.sin(u)",
            "Math.sin(u/2)*Math.sin(v) + Math.cos(u/2)*Math.sin(2*v)",
            [0, 2*π], [0, 2*π];
            strokeWidth=0.5,
            stepsU=40, stepsV=20,
        ))
    end
    push!(b, v)
end
b
```

## Vector Fields

### 14. Basic Vector Field

```@example gallery3d
b = board("vf3d_basic", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-3, 3], [-3, 3], [-3, 3]]) do v
        push!(v, vectorfield3d(
            "Math.cos(y)", "Math.sin(x)", "z",
            [-2, 5, 2], [-2, 5, 2], [-2, 5, 2];
            strokeColor="red", scale=0.5,
        ))
    end
    push!(b, v)
end
b
```

### 15. Rotational Vector Field

```@example gallery3d
b = board("vf3d_rotation", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-3, 3], [-3, 3], [-3, 3]]) do v
        push!(v, vectorfield3d(
            "-y", "x", "0",
            [-2, 4, 2], [-2, 4, 2], [-1, 2, 1];
            strokeColor="blue", scale=0.3,
        ))
    end
    push!(b, v)
end
b
```

### 16. Divergent Vector Field

```@example gallery3d
b = board("vf3d_divergent", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-3, 3], [-3, 3], [-3, 3]]) do v
        push!(v, vectorfield3d(
            "x", "y", "z",
            [-2, 4, 2], [-2, 4, 2], [-2, 4, 2];
            strokeColor="darkorange", scale=0.2,
        ))
    end
    push!(b, v)
end
b
```

## Solid Geometry

### 17. Sphere

```@example gallery3d
b = board("sphere3d_demo", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        c = point3d(0, 0, 0; size=4, name="C", color="red")
        push!(v, c)
        push!(v, sphere3d(c, 2.5;
            fillColor="blue", fillOpacity=0.3,
            strokeColor="blue", strokeOpacity=0.5,
        ))
    end
    push!(b, v)
end
b
```

### 18. Circle in 3D Space

```@example gallery3d
b = board("circle3d_demo", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        c = point3d(0, 0, 0; size=4, name="C", color="red")
        push!(v, c)
        # Circle in the xy-plane (normal along z-axis)
        push!(v, circle3d(c, [0, 0, 0, 1], 2.0;
            strokeColor="blue", strokeWidth=2,
        ))
        # Circle in the xz-plane (normal along y-axis)
        push!(v, circle3d(c, [0, 0, 1, 0], 2.0;
            strokeColor="green", strokeWidth=2,
        ))
    end
    push!(b, v)
end
b
```

### 19. 3D Polygon

```@example gallery3d
b = board("polygon3d_demo", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        p1 = point3d(0, 0, 0; size=4, name="A", color="red")
        p2 = point3d(3, 0, 0; size=4, name="B", color="blue")
        p3 = point3d(3, 3, 0; size=4, name="C", color="green")
        p4 = point3d(0, 3, 2; size=4, name="D", color="orange")
        push!(v, p1, p2, p3, p4)
        push!(v, polygon3d(p1, p2, p3, p4;
            fillColor="yellow", fillOpacity=0.3,
            strokeColor="black", strokeWidth=2,
        ))
    end
    push!(b, v)
end
b
```

### 20. 3D Plane

```@example gallery3d
b = board("plane3d_demo", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        p = point3d(0, 0, 0; size=4, name="O", color="red")
        push!(v, p)
        push!(v, plane3d(p, [1, 0, 0], [0, 1, 0];
            range_u=(-3, 3), range_v=(-3, 3),
            fillColor="lightblue", fillOpacity=0.3,
        ))
    end
    push!(b, v)
end
b
```

### 21. Polyhedron (Cube)

A `polyhedron3d` renders a solid from vertex coordinates and face definitions.
JSXGraph shades each face based on the camera angle.

```@example gallery3d
b = board("polyhedron3d_cube", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        # Cube vertices
        verts = [
            [-1, -1, -1], [ 1, -1, -1], [ 1,  1, -1], [-1,  1, -1],  # bottom
            [-1, -1,  1], [ 1, -1,  1], [ 1,  1,  1], [-1,  1,  1],  # top
        ]
        # Six faces (0-based indices)
        faces = [
            [0, 1, 2, 3],  # bottom
            [4, 5, 6, 7],  # top
            [0, 1, 5, 4],  # front
            [2, 3, 7, 6],  # back
            [0, 3, 7, 4],  # left
            [1, 2, 6, 5],  # right
        ]
        push!(v, polyhedron3d(verts, faces; fillOpacity=0.7))
    end
    push!(b, v)
end
b
```

### 22. Polyhedron (Tetrahedron)

```@example gallery3d
b = board("polyhedron3d_tetra", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        verts = [[0, 0, 0], [3, 0, 0], [1.5, 2.6, 0], [1.5, 0.87, 2.45]]
        faces = [[0, 1, 2], [0, 1, 3], [1, 2, 3], [0, 2, 3]]
        push!(v, polyhedron3d(verts, faces; fillOpacity=0.6))
    end
    push!(b, v)
end
b
```

## Intersections

### 23. Intersection Line of Two Planes

```@example gallery3d
b = board("intline3d_demo", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        p = point3d(0, 0, 0; size=4, name="O", color="black")
        push!(v, p)
        pl1 = plane3d(p, [1, 0, 0], [0, 1, 0]; range_u=(-3, 3), range_v=(-3, 3),
            fillColor="lightblue", fillOpacity=0.3)
        pl2 = plane3d(p, [1, 0, 1], [0, 1, 0]; range_u=(-3, 3), range_v=(-3, 3),
            fillColor="lightgreen", fillOpacity=0.3)
        push!(v, pl1, pl2)
        push!(v, intersectionline3d(pl1, pl2; strokeColor="red", strokeWidth=3))
    end
    push!(b, v)
end
b
```

### 24. Intersection Circle of Two Spheres

```@example gallery3d
b = board("intcirc3d_demo", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        c1 = point3d(-1, 0, 0; size=4, name="C₁", color="red")
        c2 = point3d(1, 0, 0; size=4, name="C₂", color="blue")
        push!(v, c1, c2)
        s1 = sphere3d(c1, 2.0; fillColor="red", fillOpacity=0.15)
        s2 = sphere3d(c2, 2.0; fillColor="blue", fillOpacity=0.15)
        push!(v, s1, s2)
        push!(v, intersectioncircle3d(s1, s2; strokeColor="purple", strokeWidth=3))
    end
    push!(b, v)
end
b
```

## 3D Text

### 25. Text Labels in 3D

```@example gallery3d
b = board("text3d_demo", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        push!(v, point3d(1, 0, 0; size=4, color="red"))
        push!(v, text3d(1.2, 0, 0, "X-axis"; fontSize=14))
        push!(v, point3d(0, 1, 0; size=4, color="green"))
        push!(v, text3d(0, 1.2, 0, "Y-axis"; fontSize=14))
        push!(v, point3d(0, 0, 1; size=4, color="blue"))
        push!(v, text3d(0, 0, 1.2, "Z-axis"; fontSize=14))
    end
    push!(b, v)
end
b
```

## Mesh

### 26. 3D Wireframe Mesh as Coordinate Grid

A `mesh3d` draws only wireframe lines (no fill), making it useful as a
coordinate grid or reference frame. Here three meshes form the walls of a
room — one for each coordinate plane — with a surface floating inside.

```@example gallery3d
b = board("mesh3d_demo", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-4, 4], [-4, 4], [-4, 4]]) do v
        # Floor (xy-plane at z = −3)
        push!(v, mesh3d([0, 0, -3], [1, 0, 0], [0, 1, 0], [-3, 3], [-3, 3];
            stepWidthU=1, stepWidthV=1, strokeColor="steelblue", strokeWidth=1))
        # Back wall (xz-plane at y = −3)
        push!(v, mesh3d([0, -3, 0], [1, 0, 0], [0, 0, 1], [-3, 3], [-3, 3];
            stepWidthU=1, stepWidthV=1, strokeColor="tomato", strokeWidth=1))
        # Side wall (yz-plane at x = −3)
        push!(v, mesh3d([-3, 0, 0], [0, 1, 0], [0, 0, 1], [-3, 3], [-3, 3];
            stepWidthU=1, stepWidthV=1, strokeColor="seagreen", strokeWidth=1))
        # A surface inside the "room"
        push!(v, functiongraph3d("Math.sin(x)*Math.cos(y)";
            strokeWidth=0.5, stepsU=30, stepsV=30))
    end
    push!(b, v)
end
b
```

## Combined Examples

### 27. Surface with Points

```@example gallery3d
b = board("surface_points", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-3, 3], [-3, 3], [-2, 2]]) do v
        push!(v, functiongraph3d("Math.sin(x)*Math.cos(y)";
            strokeWidth=0.5,
            stepsU=30, stepsV=30,
        ))
        # Mark some interesting points on the surface
        push!(v, point3d(0, 0, 0; size=5, color="red", name="Origin"))
        push!(v, point3d(π/2, 0, 1; size=5, color="blue", name="Max"))
        push!(v, point3d(-π/2, 0, -1; size=5, color="green", name="Min"))
    end
    push!(b, v)
end
b
```

### 28. Helix with Endpoints

```@example gallery3d
b = board("helix_endpoints", xlim=(-8, 8), ylim=(-8, 8)) do b
    v = view3d([-6, -3], [8, 8], [[-3, 3], [-3, 3], [-3, 3]]) do v
        push!(v, curve3d(
            "2*Math.cos(t)", "2*Math.sin(t)", "t/Math.PI",
            [0, 4*π];
            strokeColor="navy", strokeWidth=2,
        ))
        push!(v, point3d(2, 0, 0; size=5, color="red", name="Start"))
        push!(v, point3d(2, 0, 4; size=5, color="blue", name="End"))
    end
    push!(b, v)
end
b
```
