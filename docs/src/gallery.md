# Gallery

A comprehensive collection of JSXGraph.jl examples organized by category.
Each example is a self-contained code block that produces an interactive board.

## Basic Geometry

### 1. Points and Labels

```@example gallery
using JSXGraph
b = board("pt_labels", xlim=(-5, 5), ylim=(-5, 5)) do b
    push!(b, point(0, 0; name="O", size=4))
    push!(b, point(3, 4; name="A", color="red"))
    push!(b, point(-2, 1; name="B", color="blue", size=6))
    push!(b, point(4, -3; name="C", color="green"))
end
b
```

### 2. Line Through Two Points

```@example gallery
b = board("line_basic", xlim=(-5, 5), ylim=(-5, 5)) do b
    p1 = point(-3, -2; name="P₁")
    p2 = point(3, 2; name="P₂")
    push!(b, p1)
    push!(b, p2)
    push!(b, line(p1, p2; strokeColor="navy", strokeWidth=2))
end
b
```

### 3. Line Segment and Arrow

```@example gallery
b = board("seg_arrow", xlim=(-5, 5), ylim=(-5, 5)) do b
    a = point(-4, 0; name="A")
    bp = point(0, 3; name="B")
    c = point(4, 0; name="C")
    push!(b, a); push!(b, bp); push!(b, c)
    push!(b, segment(a, bp; strokeColor="blue", strokeWidth=2))
    push!(b, arrow(bp, c; strokeColor="red", strokeWidth=2))
end
b
```

### 4. Circle

```@example gallery
b = board("circle_ex", xlim=(-6, 6), ylim=(-6, 6)) do b
    o = point(0, 0; name="Center")
    push!(b, o)
    push!(b, circle(o, 4; strokeColor="purple", strokeWidth=2))
end
b
```

### 5. Two Concentric Circles

```@example gallery
b = board("circles_2", xlim=(-6, 6), ylim=(-6, 6)) do b
    o = point(0, 0; name="O", color="red")
    push!(b, o)
    push!(b, circle(o, 2; strokeColor="darkgreen", strokeWidth=2))
    push!(b, circle(o, 4; strokeColor="blue", strokeWidth=2))
end
b
```

### 6. Triangle

```@example gallery
b = board("triangle", xlim=(-5, 5), ylim=(-5, 5)) do b
    a = point(-3, -2; name="A")
    bp = point(3, -2; name="B")
    c = point(0, 3; name="C")
    push!(b, a); push!(b, bp); push!(b, c)
    push!(b, polygon(a, bp, c; fillColor="lightyellow", fillOpacity=0.5,
            strokeColor="darkblue", strokeWidth=2))
end
b
```

### 7. Regular Polygon

```@example gallery
b = board("regpoly", xlim=(-5, 5), ylim=(-5, 5)) do b
    p1 = point(-2, -2; name="A")
    p2 = point(2, -2; name="B")
    push!(b, p1); push!(b, p2)
    push!(b, regularpolygon(p1, p2, 6; fillColor="lightcyan", fillOpacity=0.4,
                   strokeColor="teal"))
end
b
```

### 8. Arc and Sector

```@example gallery
b = board("arc_sector", xlim=(-5, 5), ylim=(-5, 5)) do b
    o = point(0, 0; name="O")
    a = point(3, 0; name="A")
    bp = point(0, 3; name="B")
    push!(b, o); push!(b, a); push!(b, bp)
    push!(b, arc(o, a, bp; strokeColor="crimson", strokeWidth=3))
    push!(b, sector(o, a, bp; fillColor="lightsalmon", fillOpacity=0.3))
end
b
```

### 9. Angle Marker

```@example gallery
b = board("angle_ex", xlim=(-5, 5), ylim=(-5, 5)) do b
    a = point(3, 0; name="A")
    bp = point(0, 0; name="B")
    c = point(0, 3; name="C")
    push!(b, a); push!(b, bp); push!(b, c)
    push!(b, segment(bp, a; strokeColor="gray"))
    push!(b, segment(bp, c; strokeColor="gray"))
    push!(b, JSXGraph.angle(a, bp, c; radius=1.5, fillColor="lightblue", fillOpacity=0.5,
          name="α"))
end
b
```

### 10. Ellipse

```@example gallery
b = board("ellipse_ex", xlim=(-6, 6), ylim=(-4, 4)) do b
    f1 = point(-2, 0; name="F₁", color="red")
    f2 = point(2, 0; name="F₂", color="red")
    p = point(4, 0; name="P", visible=false)
    push!(b, f1); push!(b, f2); push!(b, p)
    push!(b, ellipse(f1, f2, p; strokeColor="indigo", strokeWidth=2))
end
b
```

## Function Graphs

### 11. Sine Function

```@example gallery
b = Board("sine", xlim=(-7, 7), ylim=(-2, 2))
push!(b, functiongraph("Math.sin(x)"; strokeColor="blue", strokeWidth=2))
b
```

### 12. Multiple Functions

```@example gallery
b = Board("multi_func", xlim=(-5, 5), ylim=(-3, 3))
push!(b, functiongraph("Math.sin(x)"; strokeColor="blue", strokeWidth=2, name="sin"))
push!(b, functiongraph("Math.cos(x)"; strokeColor="red", strokeWidth=2, name="cos"))
push!(b, functiongraph("Math.sin(x) + Math.cos(x)"; strokeColor="green",
          strokeWidth=2, name="sin+cos", dash=2))
b
```

### 13. Polynomial

```@example gallery
b = Board("poly_func", xlim=(-4, 4), ylim=(-10, 10))
push!(b, functiongraph("x*x*x - 3*x"; strokeColor="darkred", strokeWidth=2))
b
```

### 14. Parametric Curve (Lissajous)

```@example gallery
b = parametric(
    @jsf(t -> sin(3t)),
    @jsf(t -> cos(2t)),
    (0, 2π);
    xlim=(-1.5, 1.5), ylim=(-1.5, 1.5),
    strokeColor="purple", strokeWidth=2
)
b
```

### 15. Polar Curve (Rose)

```@example gallery
b = polar(
    @jsf(θ -> cos(3θ)),
    (0, 2π);
    xlim=(-1.5, 1.5), ylim=(-1.5, 1.5),
    strokeColor="crimson", strokeWidth=2
)
b
```

### 16. Implicit Curve

```@example gallery
b = implicit(
    @jsf((x, y) -> x^2 + y^2 - 9);
    xlim=(-5, 5), ylim=(-5, 5),
    strokeColor="darkorange", strokeWidth=2
)
b
```

### 17. Derivative Visualization

```@example gallery
b = Board("deriv", xlim=(-5, 5), ylim=(-3, 3))
f = functiongraph("Math.sin(x)"; strokeColor="blue", strokeWidth=2, name="f")
push!(b, f)
push!(b, derivative(f; strokeColor="red", strokeWidth=2, dash=2, name="f'"))
b
```

### 18. Integral (Riemann Sum)

```@example gallery
b = Board("riemann", xlim=(-1, 7), ylim=(-1, 3))
f = functiongraph("Math.sin(x)*0.5 + 1"; strokeColor="blue", strokeWidth=2)
push!(b, f)
push!(b, riemannsum(f, 12, "left"; a=0, b=6, fillColor="lightblue", fillOpacity=0.5))
b
```

### 19. Tangent and Normal Lines

```@example gallery
b = Board("tan_norm", xlim=(-5, 5), ylim=(-3, 5))
f = functiongraph("x*x/4"; strokeColor="black", strokeWidth=2)
g = glider(2, 1, f; name="P", size=4, color="red")
push!(b, f)
push!(b, g)
push!(b, tangent(g; strokeColor="green", strokeWidth=2, name="tangent"))
push!(b, normal(g; strokeColor="orange", strokeWidth=2, name="normal"))
b
```

## Interactive Elements

### 20. Slider Control

```@example gallery
b = Board("slider_ex", xlim=(-5, 5), ylim=(-5, 5))
s = slider([-4, 4], [0, 4], [1, 3, 5]; name="radius")
o = point(0, 0; name="O")
push!(b, s)
push!(b, o)
push!(b, circle(o, s; strokeColor="blue", strokeWidth=2))
b
```

### 21. Slider-Controlled Circle and Point

```@example gallery
b = Board("slider_circle", xlim=(-6, 6), ylim=(-6, 6))
r = slider([-5, 5], [1, 5], [1, 3, 5]; name="r")
o = point(0, 0; name="O", size=3)
c = circle(o, r; strokeColor="steelblue", strokeWidth=2, fillColor="steelblue", fillOpacity=0.1)
g = glider(3, 0, c; name="P", size=4, color="red")
push!(b, r); push!(b, o); push!(b, c); push!(b, g)
push!(b, segment(o, g; strokeColor="gray", dash=2))
b
```

### 22. Regular Polygon with Slider Sides

```@example gallery
b = Board("slider_polygon", xlim=(-5, 5), ylim=(-5, 5))
n = slider([-4, 4], [0, 4], [3, 5, 12]; name="n", snapWidth=1)
p1 = point(-1, 0; visible=false)
p2 = point(1, 0; visible=false)
push!(b, n); push!(b, p1); push!(b, p2)
push!(b, regularpolygon(p1, p2, n;
    fillColor="lightblue", fillOpacity=0.3, strokeColor="navy"
))
b
```

### 23. Draggable Points

```@example gallery
b = board("drag", xlim=(-5, 5), ylim=(-5, 5)) do b
    a = point(-2, 0; name="A", size=5, color="red")
    bp = point(2, 0; name="B", size=5, color="blue")
    push!(b, a); push!(b, bp)
    push!(b, segment(a, bp; strokeColor="gray", strokeWidth=2))
    push!(b, text(-4, -4, "Drag the points!"))
end
b
```

### 24. Glider on Curve

```@example gallery
b = Board("glider_ex", xlim=(-5, 5), ylim=(-5, 5))
o = point(0, 0; name="O", visible=false)
c = circle(o, 3; strokeColor="gray")
g = glider(3, 0, c; name="G", size=5, color="orange")
push!(b, o)
push!(b, c)
push!(b, g)
push!(b, segment(o, g; strokeColor="orange", dash=2))
b
```

### 25. Text Annotation

```@example gallery
b = Board("text_ex", xlim=(-5, 5), ylim=(-5, 5))
push!(b, text(-4, 4, "Hello JSXGraph!"))
push!(b, text(-4, 2, "<b>Bold</b> and <i>italic</i>"))
push!(b, point(0, 0; name="Origin", color="red"))
b
```

### 26. Image on Board

```@example gallery
b = Board("image_ex", xlim=(-5, 5), ylim=(-5, 5))
# Original image is 1441×378 px → ratio ≈ 3.81:1
push!(b, image("assets/logo_jsxgraph.png",
          [-4, 4], [8, 2.1]))
push!(b, text(-2, -3, "JSXGraph logo"))
b
```

## Data Visualization

### 27. Scatter Plot

```@example gallery
x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
y = [2.1, 3.9, 6.2, 7.8, 10.1, 12.3, 13.8, 16.1]
b = scatter(x, y; color="steelblue", size=4)
b
```

### 28. Function Plot with Domain

```@example gallery
b = plot(@jsf(x -> x^2 - 4), (-4, 4); strokeColor="darkgreen", strokeWidth=2)
b
```

### 29. Multiple Data Series

```@example gallery
x = collect(0.0:0.5:6.0)
y1 = sin.(x)
y2 = cos.(x)
b = scatter(x, y1; color="blue", size=3, xlim=(-1, 7), ylim=(-1.5, 1.5))
for (xi, yi) in zip(x, y2)
    push!(b, point(xi, yi; color="red", size=3, name=""))
end
b
```

## Composition & Transforms

### 30. Do-Block Syntax

```@example gallery
b = board("doblock", xlim=(-5, 5), ylim=(-5, 5)) do b
    a = point(-3, 0; name="A", color="crimson")
    bp = point(3, 0; name="B", color="navy")
    c = point(0, 4; name="C", color="forestgreen")
    push!(b, a); push!(b, bp); push!(b, c)
    push!(b, polygon(a, bp, c; fillColor="#ffe0e0", fillOpacity=0.5))
    push!(b, segment(a, bp; strokeColor="gray", dash=2))
    push!(b, segment(bp, c; strokeColor="gray", dash=2))
    push!(b, segment(c, a; strokeColor="gray", dash=2))
end
b
```

### 31. Board Composition with `+`

```@example gallery
b = Board("compose", xlim=(-5, 5), ylim=(-5, 5))
p = point(0, 0; name="O")
b = b + p + circle(p, 3; strokeColor="blue") + functiongraph("Math.sin(x)"; strokeColor="red")
b
```

### 32. Grid and Axes

```@example gallery
b = Board("grid_axes", xlim=(-5, 5), ylim=(-5, 5))
o = point(0, 0); px = point(1, 0); py = point(0, 1)
push!(b, o); push!(b, px); push!(b, py)
push!(b, axis(o, px; name="x"))
push!(b, axis(o, py; name="y"))
push!(b, grid())
b
```

## Theming

### 33. Dark Theme

```@example gallery
b = with_theme(THEME_DARK) do
    board("dark_ex", xlim=(-5, 5), ylim=(-5, 5)) do b
        push!(b, point(0, 0; name="O"))
        push!(b, functiongraph("Math.sin(x)"; strokeColor="#ff6688"))
    end
end
b
```

### 34. Publication Theme

```@example gallery
b = with_theme(THEME_PUBLICATION) do
    board("pub_ex", xlim=(-5, 5), ylim=(-5, 5)) do b
        push!(b, functiongraph("x*x/5 - 2"; strokeWidth=2, name="f(x) = x²/5 − 2"))
        push!(b, point(0, -2; name="vertex"))
    end
end
b
```

## Advanced Examples

### 35. Slope Field

```@example gallery
b = Board("slope", xlim=(-5, 5), ylim=(-5, 5))
push!(b, slopefield("x - y"; strokeColor="lightblue"))
push!(b, functiongraph("x - 1 + Math.exp(-x)"; strokeColor="red", strokeWidth=2))
b
```

### 36. Inequality Region

```@example gallery
b = Board("ineq", xlim=(-5, 5), ylim=(-5, 5))
f = functiongraph("Math.sin(x)*2"; strokeColor="blue", strokeWidth=2)
push!(b, f)
push!(b, inequality(f; fillColor="lightblue", fillOpacity=0.3, inverse=false))
b
```

### 37. JavaScript Function Bridge

```@example gallery
b = Board("jsf_ex", xlim=(-5, 5), ylim=(-5, 5))
push!(b, functiongraph(@jsf(x -> sin(x) * cos(2x)); strokeColor="purple", strokeWidth=2))
b
```
