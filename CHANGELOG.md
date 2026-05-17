# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Apply JuliaFormatter v2.3.0 (blue style) across the codebase. Whitespace-only changes — no behavior change. The `Format Check` workflow was added recently and only runs on pull requests, so the v1→v2 style drift on `main` had gone unnoticed until CompatHelper PRs (#13, #14, #15) tripped the check.
- `_normalize_theme` accepts any `AbstractDict` (previously `Dict` only). This lets `load_theme` work with JSON.jl v1, whose `parsefile` returns `JSON.Object{String,Any} <: AbstractDict` rather than `Dict{String,Any}`. Tests pass against both JSON 0.21 and 1.6.

## [0.5.3] - 2026-05-13

### Added

- `@jsf` now transpiles Julia property-access expressions (`obj.prop`) and method-call syntax (`obj.prop()`) to their JS equivalents. Combined with the v0.5.2 element-ref capture, this enables the classic JSXGraph wiki idiom of using a draggable point's live coordinate inside a function expression, e.g. `@jsf x -> α.X()^x` where `α` is a `point`.
- `line(c::Real, b::Real, a::Real; kwargs...)` — three-argument constructor accepting JSXGraph's homogeneous-coordinate line form `c + b·x + a·y = 0`. Convenient as the boundary parent of an `inequality` element.
- New documentation page **Wiki Examples** (`docs/src/wiki_examples.md`) reproducing the first batch of slider-driven examples from the JSXGraph upstream wiki: draggable-exponential function (`A.Y()^(x/A.X())` with point on the curve by construction), Lituus polar spiral with `k` slider, P-Norm unit ball, slider-driven quartic polynomial, Taylor approximations of `sin` with truncation-order slider via raw `JSFunction`, three-slider (`n`, start, end) Riemann sum, and linear half-plane inequalities. Tracks the wishlist from #6.

### Changed

- `_call_to_js` now routes non-`Symbol` call heads (e.g. an `Expr(:.)` for `point.X()`) through `julia_to_js`, fixing syntactically-invalid JS that was previously emitted as a Julia-style `repr(::Expr)`. Bare `Symbol` call heads (math functions, `named_jsf` references, JS builtins) keep their existing fast path.

## [0.5.2] - 2026-05-13

### Fixed

- `@jsf` now resolves free Julia symbols that reference `JSXElement` values (typically sliders) to their JS variable. Previously `@jsf x -> s * x^2` emitted an undefined `s` identifier in the rendered JavaScript and the dependent element silently failed to render. Slider references auto-append `.Value()`, so the documented `s * x^2` idiom from the tutorial works as-is.

### Added

- Free symbols in `@jsf` lambdas that resolve to `Real`, `Bool`, or `AbstractString` Julia bindings are inlined as JS literals (e.g. `@jsf x -> x + k` with `k = 3.14` emits `x + 3.14`).
- `JSFunction` gains an internal `refs::Dict{String,Any}` field that records captured Julia bindings for placeholder substitution at render time. Backward-compatible constructors are preserved.

### Changed

- The JS `val`, `valx`, `valy` helpers in `board.jl`'s `PREAMBLE` are now idempotent on numbers (`typeof x === "number" ? x : x.Value()`), making `val(s)` safe to use alongside the new auto-deref.

## [0.5.1] - 2026-05-13

### Fixed

- `scatter(x, y)` and `plot(table, :x, :y)` (Tables.jl extension) no longer produce an invalid `(NaN, NaN, NaN, NaN)` bounding box when the data contains `NaN` or `Inf`. Non-finite values are filtered before computing the auto-padded axis range, with a safe `(-1.0, 1.0)` fallback when no finite values remain. This unblocks the classic JSXGraph scatter-via-curve idiom (`[x, x, NaN, ...]`) when using the auto-axis path.

## [0.5.0] - 2026-05-13

### Added

- Pluto `@bind` integration via `bindable=true` keyword on `board(...)`. The bound state exposes draggable points (2D + 3D) and sliders by name; helpers `points_xy` and `points_xyz` project to parallel coordinate vectors for spline / regression / array workflows. New optional weak dependency on `AbstractPlutoDingetjes` (loaded automatically by Pluto) routes seed coordinates through Pluto's `published_to_js` channel for efficiency; outside Pluto a JSON-inline fallback keeps the feature working with zero new dependencies. Duplicate element names on a bindable board raise `ArgumentError` at construction. Docs include a runnable Pluto example notebook (`docs/notebooks/pluto_bind_demo.jl`) downloadable from the new **Pluto Integration** page; the page can also embed the rendered notebook via `PlutoStaticHTML.jl` when the docs are built with `BUILD_PLUTO_NOTEBOOKS=true`. Fixes #12.
- 3D viewport support via `View3D` container type with `do`-block syntax (REQ-3D-001)
- 3D element constructors: `point3d`, `line3d`, `curve3d`, `functiongraph3d`, `parametricsurface3d` (REQ-3D-002 to REQ-3D-005)
- `view3d` constructor with keyword arguments (`xlim`, `ylim`, `zlim`) and positional form
- `push!` support for `View3D` containers
- `vectorfield3d` constructor for 3D vector fields (REQ-3D-014)
- `sphere3d`, `circle3d`, `polygon3d`, `plane3d` constructors for 3D solid geometry (REQ-3D-010 to REQ-3D-013)
- `intersectionline3d`, `intersectioncircle3d` constructors for 3D intersections (REQ-3D-015, REQ-3D-016)
- `text3d` constructor for 3D text labels (REQ-3D-018)
- `mesh3d` constructor for 3D wireframe mesh grids (REQ-3D-017)
- `polyhedron3d` constructor for 3D solids with shaded faces (REQ-3D-019)
- 3D theming support: `THEME_DARK` and `THEME_PUBLICATION` include defaults for all 3D element types (REQ-3D-020)
- 3D attribute aliases: `surfacecolor`, `surfaceopacity`, `wireframecolor`, `wireframewidth`, `meshcolor`, `meshwidth` (REQ-3D-021)
- 3D gallery documentation page with 28 interactive examples (REQ-3D-006)
- 3D Elements documentation section in Geometric Elements page
- Observables.jl integration: `Observable` values as element parents and attributes are automatically unwrapped at render time (REQ-INT-011)
- Gallery documentation page with 37 categorized examples including slider-driven interactive demos (REQ-DOC-002, REQ-DOC-003)
- MathJS integration: `enable_mathjs!()` / `disable_mathjs!()` to extend `@jsf` with `gamma`, `erf`, `factorial`, and 20+ additional math functions via MathJS CDN (REQ-JSF-003)

### Fixed

- 3D gallery examples now use `axis=false` on the board so only the `View3D` axes are rendered (previously the 2D board axes and the 3D view axes were drawn simultaneously)
- `functiongraph3d` now automatically inherits x/y ranges from parent `View3D` when not explicitly provided, fixing `Surface3D.updateWireframe` crash
- CDN fragment loader now correctly detects RequireJS (checks `requirejs` global) instead of failing on Pluto.jl's custom `require`
- String arguments to `functiongraph`, `slopefield`, `vectorfield`, `implicitcurve` are now wrapped as JavaScript function expressions instead of being JSON-quoted as JessieCode strings
- `slopefield`, `vectorfield`, and `implicitcurve` correctly generate 2-parameter `function(x,y)` wrappers for string inputs
- Strings starting with `function` are passed through as-is (e.g., `"function(x){ return x*x; }"`)
- `riemannsum` now extracts the underlying `JSFunction` from `JSXElement` parents (e.g., passing a `functiongraph` element as the function argument)
- `slopefield` and `vectorfield` now pass required `xData` and `yData` grid parameters to JSXGraph (fixes empty slope fields)
- Gallery image example uses local asset instead of broken external URL
- RequireJS-compatible loader for JSXGraph fragment embedding in Documenter.jl environments
- Board initialization wrapped in try/catch to prevent cascade failures when one board errors in RequireJS environments

### Added (continued)

- `@jsxrecipe` macro for defining custom type recipes via method dispatch (REQ-ECO-020)
- `JSXGraphRecipesBase.jl` lightweight interface package for recipe system (REQ-ECO-021)
- `ElementSpec` intermediate representation type for recipe output
- `realize_specs` function to convert recipe specs into concrete `JSXElement`s
- `plot!` and `plot` functions for applying recipes to boards
- `Board + custom_object` operator overload for recipe types
- `has_recipe` function to check if a type has a registered recipe
- Recipe System documentation page
- SVG export via `save("file.svg", board)` using NodeJS_22_jll + jsdom headless rendering (REQ-ECO-011)
- PNG export via `save("file.png", board)` using NodeJS_22_jll + jsdom + sharp (REQ-ECO-012)
- PDF export via `save("file.pdf", board)` using NodeJS_22_jll + jsdom + pdfkit + svg-to-pdfkit (REQ-ECO-012)
- `save_svg`, `save_png`, `save_pdf` functions for programmatic export (via `JSXGraphNodeJSExt` package extension)
- `save()` dispatches on file extension (`.html` / `.svg` / `.png` / `.pdf`), errors on unsupported formats
- PNG `scale` parameter for high-DPI/Retina output (e.g. `save("plot.png", b; scale=2)`)
- `NodeJS_22_jll` as weak dependency — Node.js v22 via Julia artifacts, no system install needed
- HTML size warning when generated content exceeds 1 MB (excluding library assets) (REQ-PERF-003)
- HTML snapshot tests for 10 major element types to detect regressions (REQ-QA-002)
- 9 composition and transformation element constructors: `group`, `transformation`, `reflection`, `rotation`, `translation`, `grid`, `axis`, `ticks`, `legend` (REQ-GEO-004)
- Theming system with `set_theme!`, `reset_theme!`, `with_theme`, `current_theme` (REQ-API-020)
- Three built-in themes: `THEME_DEFAULT`, `THEME_DARK`, `THEME_PUBLICATION` (REQ-API-021)
- Custom theme support via `register_theme!` and `load_theme` from TOML/JSON files (REQ-API-022)
- Board-level theme defaults (e.g., background color) applied automatically
- Themes documentation page
- `save(filename, board)` function for writing self-contained HTML files (REQ-ECO-010)
- `@jsf` macro for compile-time Julia-to-JavaScript transpilation with validation (REQ-JSF-001)
- Unsupported construct detection in `@jsf` (try/catch, loops, comprehensions, multi-statement bodies) (REQ-JSF-002)
- `scatter(x, y)` convenience function for scatter plots with auto-computed axis limits (REQ-API-002)
- `parametric(fx, fy, t_range)` convenience function for parametric curves (REQ-API-002)
- `implicit(F)` convenience function for implicit curves (REQ-API-002)
- `polar(r, θ_range)` convenience function for polar curves (REQ-API-002)
- `board()` do-block syntax for idiomatic board construction (REQ-API-004)
- Tables.jl data ingestion: `scatter(table, :x, :y)` and `plot(table, :x, :y)` for any Tables.jl-compatible source (REQ-ECO-001)
- Unitful.jl integration: automatic unit stripping, axis labels with unit annotations, and consistent unit conversion for `point`, `scatter`, `plot`, and `Board` (REQ-ECO-002)
- Getting Started tutorial page in documentation (REQ-DOC-001)
- Named JSFunction support (`@named_jsf`, `named_jsf`) and transitive dependency resolution (`with_deps`) for composing `@jsf` functions (REQ-GEO-012)

## [0.5.0] - 2026-03-01

### Added

- Plots.jl-compatible attribute aliases (`color`, `linewidth`, `fillcolor`, `opacity`, `linestyle`, `markersize`, `label`, `legend`)
- Short alias shorthand for rapid prototyping (`col`, `lw`, `fill`, `alpha`, `ls`, `ms`)
- Colors.jl integration for automatic color type conversion to CSS strings (RGB, RGBA, HSL, named colors)
- Three-tier precedence system: JSXGraph-native names > full aliases > short aliases
- Multi-target alias expansion (`opacity`/`alpha` → both `strokeOpacity` and `fillOpacity`)
- Attribute Aliases documentation page

## [0.4.0] - 2026-02-28

### Added

- `JSXElement` type for representing JSXGraph geometric elements
- `JSFunction` type for JavaScript function strings
- 14 geometric primitive constructors: `point`, `line`, `segment`, `arrow`, `circle`, `arc`, `sector`, `polygon`, `regularpolygon`, `angle`, `conic`, `ellipse`, `parabola`, `hyperbola`
- 11 analytic element constructors: `functiongraph`, `curve`, `implicitcurve`, `inequality`, `tangent`, `normal`, `integral`, `derivative`, `riemannsum`, `slopefield`, `vectorfield`
- 8 interactive element constructors: `slider`, `checkbox`, `input`, `button`, `glider`, `tapemeasure`, `text`, `image`
- `push!` and `+` operators for board composition
- `julia_to_js()` for converting Julia expressions and functions to JavaScript
- High-level `plot(f, domain)` convenience function
- Geometric Elements documentation page

## [0.3.0] - 2026-02-28

### Added

- Automatic Board display in notebooks via `text/html` MIME (Jupyter, VS Code, Pluto.jl)
- Compact text representation in REPL via `text/plain` MIME
- `open_in_browser()` function for opening boards in the default browser (requires DefaultApplication.jl)
- Pluto.jl and Documenter.jl compatibility for interactive board rendering
- Display Protocol documentation page

## [0.2.0] - 2026-02-28

### Added

- HTML generation engine (`html_string`, `html_page`, `html_fragment`)
- Board keyword constructor with `xlim`, `ylim`, `axis`, `grid`, `width`, `height` options
- CDN asset loading mode (`asset_mode=:cdn`) for smaller HTML output
- JSXGraph 1.12.2 bundled via Julia Artifacts system
- `JSXGRAPH_VERSION` constant for querying bundled library version
- HTML Generation documentation page

## [0.1.0] - 2026-02-28

### Added

- Initial package structure with `Project.toml`, `src/`, `test/`, `docs/`
- Core types: `AbstractJSXElement` (abstract supertype) and `Board` (container)
- Package extensions for Colors.jl, Unitful.jl, Tables.jl, and Observables.jl
- Documenter.jl documentation with GitHub Pages deployment
- GitHub Actions CI for Julia LTS, stable, and nightly on Linux, macOS, Windows
- JuliaFormatter configuration with BlueStyle
- CONTRIBUTING.md and issue templates
