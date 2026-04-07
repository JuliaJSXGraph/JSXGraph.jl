# MathJS Integration

JSXGraph.jl can optionally use the [MathJS](https://mathjs.org/) library to extend the set of mathematical functions available in `@jsf` transpilation. This enables functions like `gamma`, `erf`, `factorial`, and more that are not available in JavaScript's built-in `Math` object.

## Enabling MathJS

MathJS integration is opt-in. Enable it before using MathJS-specific functions:

```julia
using JSXGraph

enable_mathjs!()

# Now you can use gamma, erf, factorial, etc. in @jsf
f = @jsf x -> gamma(x)
fg = functiongraph(f)

b = Board("mathjs_demo", xlim=(0, 5), ylim=(-5, 10))
push!(b, fg)
```

When MathJS is enabled, the generated HTML automatically includes the MathJS library from CDN.

## Disabling MathJS

```julia
disable_mathjs!()

# gamma(x) will now be emitted as-is: "gamma(x)" (not "math.gamma(x)")
```

## Supported MathJS Functions

When MathJS is enabled, these additional functions are recognized by `@jsf` and `julia_to_js`:

| Julia Function | JavaScript Output | Category |
|---|---|---|
| `gamma(x)` | `math.gamma(x)` | Special functions |
| `erf(x)` | `math.erf(x)` | Special functions |
| `factorial(n)` | `math.factorial(n)` | Special functions |
| `combinations(n, k)` | `math.combinations(n, k)` | Combinatorics |
| `permutations(n, k)` | `math.permutations(n, k)` | Combinatorics |
| `gcd(a, b)` | `math.gcd(a, b)` | Number theory |
| `lcm(a, b)` | `math.lcm(a, b)` | Number theory |
| `mod(a, b)` | `math.mod(a, b)` | Number theory |
| `cbrt(x)` | `math.cbrt(x)` | Roots |
| `nthroot(x, n)` | `math.nthRoot(x, n)` | Roots |
| `sec(x)` | `math.sec(x)` | Trigonometric |
| `csc(x)` | `math.csc(x)` | Trigonometric |
| `cot(x)` | `math.cot(x)` | Trigonometric |
| `asec(x)` | `math.asec(x)` | Inverse trigonometric |
| `acsc(x)` | `math.acsc(x)` | Inverse trigonometric |
| `acot(x)` | `math.acot(x)` | Inverse trigonometric |
| `asinh(x)` | `math.asinh(x)` | Inverse hyperbolic |
| `acosh(x)` | `math.acosh(x)` | Inverse hyperbolic |
| `atanh(x)` | `math.atanh(x)` | Inverse hyperbolic |
| `mean(...)` | `math.mean(...)` | Statistics |
| `median(...)` | `math.median(...)` | Statistics |
| `std(...)` | `math.std(...)` | Statistics |
| `variance(...)` | `math.variance(...)` | Statistics |

## Coexistence with Standard Math Functions

Standard `Math.*` functions (`sin`, `cos`, `exp`, `log`, `sqrt`, `abs`, etc.) continue to work normally when MathJS is enabled. MathJS functions are only used for names not already covered by `Math.*`:

```julia
enable_mathjs!()

# sin → Math.sin (standard), gamma → math.gamma (MathJS)
f = @jsf x -> sin(x) + gamma(x)
# Produces: "function(x){return Math.sin(x) + math.gamma(x);}"
```

## MathJS Version

The MathJS library version is pinned for reproducibility:

```julia
MATHJS_VERSION   # e.g., "13.2.2"
MATHJS_CDN_JS    # full CDN URL
```

## API Reference

```@docs
enable_mathjs!
disable_mathjs!
mathjs_enabled
```
