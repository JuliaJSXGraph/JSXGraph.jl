# JSXGraph Wiki Examples

A growing collection of interactive examples ported from the
[JSXGraph upstream wiki](https://jsxgraph.org/wiki/index.php/Main_Page).
Each example highlights the **slider-driven interactivity** that makes JSXGraph
distinctive: drag the on-board sliders to update parameters in real time.

This page tracks the wishlist from
[issue #6](https://github.com/JuliaJSXGraph/JSXGraph.jl/issues/6).

## 1. Draggable exponential function

A draggable anchor point `A` whose coordinates `(A.X(), A.Y())` parameterize
an exponential `f(x) = A.Y()^(x / A.X())`. The clever bit: at `x = A.X()` the
formula collapses to `A.Y()^1 = A.Y()`, so **`A` always lies on the curve** by
construction — drag it anywhere and the curve follows.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Draggable_exponential_function)

```@example wiki_examples
using JSXGraph

board("wiki_exp", xlim=(-3, 3), ylim=(-1, 10)) do brd
    A = point(1.0, exp(1); name="A", color="red", size=4)
    push!(brd, A)
    push!(brd, functiongraph(@jsf x -> A.Y()^(x / A.X()); strokeColor="blue", strokeWidth=2))
end
```

## 2. Lituus

The Lituus is the polar spiral `r(φ) = √(k/φ)` with `k` controlled by a
slider. As `k` grows the spiral widens; as `k → 0` it collapses onto the
origin.

The standalone [`polar`](@ref) constructor creates its own board, which keeps
us from putting a slider alongside it. Instead we build the polar curve
manually as a parametric one — `x(t) = r(t)·cos(t)`, `y(t) = r(t)·sin(t)` —
so the slider captured inside `@jsf` flows through both component functions
at render time.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Lituus)

```@example wiki_examples
board("wiki_lituus", xlim=(-3, 5), ylim=(-3, 9)) do brd
    k = slider([1, 8], [5, 8], [0, 1, 4]; name="k")
    push!(brd, k)
    push!(brd, curve(
        @jsf(t -> sqrt(k / t) * cos(t)),
        @jsf(t -> sqrt(k / t) * sin(t)),
        0.0001, 8π;
        strokeColor="purple", strokeWidth=1,
    ))
end
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

A slider `N` controls the truncation order of the Taylor series for `sin(t)`.
Drag `N` from 0 upward and watch the polynomial approximation extend its
agreement with `sin(t)` further from the origin.

`@jsf` does not transpile Julia `for` / `while` loops to JavaScript (they live
in [`UNSUPPORTED_EXPR_HEADS`](https://github.com/JuliaJSXGraph/JSXGraph.jl/blob/main/src/jsfunction.jl)),
so the truncated-series body is written as a raw `JSXGraph.JSFunction`. The
placeholder marker `__JSF_REF_s__` is substituted at render time to the slider's
JS variable (with `.Value()` auto-appended for sliders), the same mechanism the
`@jsf` macro uses internally for captured element references.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Power_Series_for_sine)

```@example wiki_examples
board("wiki_taylor", xlim=(-10, 10), ylim=(-3, 3)) do brd
    # Reference sin(t) in light gray
    push!(brd, functiongraph(@jsf t -> sin(t); strokeColor="#cccccc", strokeWidth=2))

    # Slider for truncation order N ∈ [0, 10]
    s = slider([-9, -2.5], [9, -2.5], [0, 1, 10]; name="N", snapWidth=1)
    push!(brd, s)

    # Truncated Taylor sum: sum_{k=0}^{N} (-1)^k · t^(2k+1) / (2k+1)!
    # Written as raw JS because @jsf cannot transpile for-loops.
    code = """function(t){
        var v = 0, k, sv = __JSF_REF_s__ + 1, a;
        for (k = 0; k < sv; k++) {
            a = 1;
            for (var j = 1; j <= 2*k + 1; j++) a *= j;
            v += Math.pow(-1, k) * Math.pow(t, 2*k + 1) / a;
        }
        return v;
    }"""
    fn = JSXGraph.JSFunction(code, "", JSXGraph.JSFunction[], Dict{String,Any}("__JSF_REF_s__" => s))
    push!(brd, functiongraph(fn; strokeColor="blue", strokeWidth=2))
end
```

## 6. Riemann sums (n, start, end sliders)

Three sliders drive the left-endpoint Riemann sum approximating
`∫ₐᵇ sin(x) dx`:

- `n` — number of subintervals
- `start` — lower bound `a`
- `end` — upper bound `b`

The shaded curve segment between `a` and `b` (drawn with `functiongraph`)
updates together with the rectangles as the bounds slide.

JSXGraph's `functiongraph` and `riemannsum` expect their range parents
(`xmin`, `xmax`, `n`) to be either a literal number or a **function returning
a number**, not a slider element reference. We wrap each slider in a tiny
no-arg lambda — `@jsf () -> a_slider` — which transpiles to
`function(){return el_xxx.Value();}` thanks to the slider-auto-deref in
JSXGraph.jl. This matches the JSXGraph wiki idiom verbatim.

The functiongraph's 3-parent form (`f, xmin, xmax`) isn't exposed in the
public API yet, so the example reaches for the internal
`JSXGraph._create_element("functiongraph", (f, xmin, xmax), …)`.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Riemann_sums)

```@example wiki_examples
board("wiki_riemann", xlim=(-8, 8), ylim=(-4, 4)) do brd
    n = slider([1, 3], [5, 3], [1, 10, 50]; name="n",     snapWidth=1)
    a = slider([1, 2], [5, 2], [-10, -3, 0]; name="start")
    b = slider([1, 1], [5, 1], [0, π, 10];   name="end")
    push!(brd, n, a, b)

    f      = @jsf x -> sin(x)
    get_a  = @jsf () -> a
    get_b  = @jsf () -> b
    get_n  = @jsf () -> n

    # functiongraph plotted only between the slider-driven bounds
    push!(brd, JSXGraph._create_element("functiongraph", (f, get_a, get_b),
                                        Dict(:strokeColor => "blue",
                                             :strokeWidth => 2)))

    # left-endpoint Riemann sum with bounds and subdivision count driven
    # by the same sliders
    push!(brd, riemannsum(f, get_n, "left";
                           a=get_a, b=get_b,
                           fillColor="yellow", fillOpacity=0.4))
end
```

## 7. Linear inequalities (half-planes)

The wiki page demonstrates the `inequality` element on **linear** boundaries,
specifying each line in its homogeneous-coordinate form `c + b·x + a·y = 0`.
The shaded side is the `… ≤ 0` half-plane by default; `inverse=true` flips it
to `… ≥ 0`.

The 3-coefficient `line(c, b, a)` constructor (added in v0.5.3) accepts this
form directly.

[JSXGraph wiki source](https://jsxgraph.org/wiki/index.php/Inequalities)

```@example wiki_examples
board("wiki_ineq", xlim=(-5, 5), ylim=(-5, 5)) do brd
    # Line `2x - y + 3 = 0`  (i.e. y = 2x + 3); shade `2x - y + 3 ≤ 0`
    l1 = line(3, 2, -1)
    push!(brd, l1)
    push!(brd, inequality(l1; fillColor="yellow"))

    # Line `x - 3 = 0`  (i.e. x = 3); shade `x ≥ 3` via `inverse=true`
    l2 = line(-3, 1, 0; strokeColor="black")
    push!(brd, l2)
    push!(brd, inequality(l2; fillColor="red", inverse=true))
end
```
