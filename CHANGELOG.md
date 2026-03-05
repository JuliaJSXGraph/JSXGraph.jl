# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

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
