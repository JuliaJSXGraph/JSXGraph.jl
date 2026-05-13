# JSXGraph Wiki Examples

A growing collection of interactive examples ported from the
[JSXGraph upstream wiki](https://jsxgraph.org/wiki/index.php/Main_Page).
Each example highlights the **slider-driven interactivity** that makes JSXGraph
distinctive: drag the on-board sliders to update parameters in real time.

This page tracks the wishlist from
[issue #6](https://github.com/JuliaJSXGraph/JSXGraph.jl/issues/6).

## 1. Draggable exponential function

Vary the base `a` of `f(x) = aˣ` with a slider.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Draggable_exponential_function)

```@example wiki_examples
using JSXGraph

board("wiki_exp", xlim=(-5, 5), ylim=(-2, 10)) do brd
    a = slider([-4, -1], [4, -1], [0.1, 2.0, 5.0]; name="a")
    push!(brd, a)
    push!(brd, functiongraph(@jsf x -> a^x; strokeColor="blue", strokeWidth=2))
end
```

## 2. Lituus

The Lituus is the polar curve `r(θ) = 1/√θ`.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Lituus)

```@example wiki_examples
polar(@jsf(θ -> 1 / sqrt(θ)), (0.1, 8π);
      xlim=(-3, 3), ylim=(-3, 3),
      strokeColor="purple", strokeWidth=2)
```

## 3. P-Norm unit ball

The unit "circle" in the p-norm is the implicit curve `|x|^p + |y|^p = 1`.
A slider varies `p` continuously between `0.5` and `5.0`, morphing the shape
from a four-pointed star (`p < 1`) through a Euclidean circle (`p = 2`) to a
square (`p → ∞`).

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/P-Norm)

```@example wiki_examples
board("wiki_pnorm", xlim=(-1.5, 1.5), ylim=(-1.5, 1.5)) do brd
    p = slider([-1.3, 1.3], [1.3, 1.3], [0.5, 2.0, 5.0]; name="p")
    push!(brd, p)
    push!(brd, implicitcurve(@jsf (x, y) -> abs(x)^p + abs(y)^p - 1;
                              strokeColor="darkred", strokeWidth=2))
end
```

## 4. Slider-driven polynomial

A quartic `a·x⁴ + b·x³ + c·x² + d·x` with one slider per coefficient. Drag the
sliders to reshape the curve in real time.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Polynomials)

```@example wiki_examples
board("wiki_poly", xlim=(-4, 4), ylim=(-10, 10)) do brd
    a = slider([-3, 8], [3, 8], [-2, 0.5, 2]; name="a")
    b = slider([-3, 7], [3, 7], [-3, 0, 3];   name="b")
    c = slider([-3, 6], [3, 6], [-3, 0, 3];   name="c")
    d = slider([-3, 5], [3, 5], [-3, 0, 3];   name="d")
    push!(brd, a, b, c, d)
    push!(brd, functiongraph(@jsf x -> a * x^4 + b * x^3 + c * x^2 + d * x;
                              strokeColor="darkred", strokeWidth=2))
end
```

## 5. Power series for sine

Compare `sin(x)` (black) with successive Taylor approximations of order 1, 3,
5, 7, 9. The approximation hugs the reference closer to the origin and
diverges further out as the order grows.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Power_Series_for_sine)

```@example wiki_examples
board("wiki_taylor", xlim=(-10, 10), ylim=(-3, 3)) do brd
    push!(brd, functiongraph(@jsf x -> sin(x); strokeColor="black", strokeWidth=2))
    push!(brd, functiongraph(@jsf x -> x;                                                   strokeColor="red"))
    push!(brd, functiongraph(@jsf x -> x - x^3 / 6;                                         strokeColor="orange"))
    push!(brd, functiongraph(@jsf x -> x - x^3 / 6 + x^5 / 120;                             strokeColor="green"))
    push!(brd, functiongraph(@jsf x -> x - x^3 / 6 + x^5 / 120 - x^7 / 5040;                strokeColor="blue"))
    push!(brd, functiongraph(@jsf x -> x - x^3 / 6 + x^5 / 120 - x^7 / 5040 + x^9 / 362880; strokeColor="purple"))
end
```

A fully-dynamic version (single slider `n` driving an arbitrary truncation) is
tracked separately — it requires emitting a hand-written JS loop because the
`@jsf` macro does not yet support `for`/`while`.

## 6. Riemann sum (variable n)

A slider over the number of subintervals `n` controls the left-endpoint Riemann
approximation of `∫₀^π sin(x) dx`. Drag the slider and watch the sum converge
toward the exact value (`2.0`).

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Riemann_sums)

```@example wiki_examples
board("wiki_riemann", xlim=(-1, 5), ylim=(-1.5, 1.5)) do brd
    n = slider([0, 1.3], [4, 1.3], [1, 10, 50]; name="n", snapWidth=1)
    push!(brd, n)
    fg = functiongraph(@jsf(x -> sin(x)); strokeColor="blue", strokeWidth=2)
    push!(brd, fg)
    push!(brd, riemannsum(@jsf(x -> sin(x)), n, "left";
                           a=0, b=π, fillColor="yellow", fillOpacity=0.4))
end
```

## 7. Inequality region with slider

Shade the region `y ≤ sin(a·x)` where `a` is controlled by a slider, illustrating
how the frequency parameter reshapes the inequality region.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Inequalities)

```@example wiki_examples
board("wiki_ineq", xlim=(-5, 5), ylim=(-5, 5)) do brd
    a = slider([-4, 4], [4, 4], [-3, 1, 3]; name="a")
    push!(brd, a)
    f = functiongraph(@jsf x -> sin(a * x); strokeColor="blue", strokeWidth=2)
    push!(brd, f)
    push!(brd, inequality(f; fillColor="lightblue", fillOpacity=0.3))
end
```
