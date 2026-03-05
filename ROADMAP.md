# Roadmap

This document tracks the development roadmap for **JSXGraph.jl**, organized by phase as defined in the [spec.md](spec.md) requirements specification.

Legend: ✅ Done | 🔧 Partial | ⬜ Not started

---

## Phase 1 — Foundation

> Core architecture, display protocol, basic geometric elements, and packaging.

| Requirement | Description | Status |
|---|---|---|
| REQ-ARCH-001 | Self-contained HTML/JS/CSS output | ✅ |
| REQ-ARCH-002 | JSXGraph assets via Julia Artifacts | ✅ |
| REQ-ARCH-003 | Lightweight dependencies (no Blink.jl) | ✅ |
| REQ-ARCH-004 | Time-to-first-plot under 2 seconds | ✅ |
| REQ-DISP-001 | `text/html` MIME for Board | ✅ |
| REQ-DISP-002 | Jupyter/IJulia inline rendering | ✅ |
| REQ-DISP-003 | Pluto.jl reactive compatibility | ✅ |
| REQ-DISP-004 | VS Code plot pane rendering | ✅ |
| REQ-DISP-005 | REPL → open in browser (`DefaultApplication.jl`) | ✅ |
| REQ-DISP-006 | Franklin/Documenter embeddable fragments | ✅ |
| REQ-GEO-001 | 14 geometric primitive constructors | ✅ |
| REQ-GEO-002 | 11 analytic/functional element constructors | ✅ |
| REQ-GEO-003 | 8 interactive element constructors | ✅ |
| REQ-API-001 | High-level `plot(f, domain)` | ✅ |
| REQ-API-003 | `push!` / `+` composition operators | ✅ |
| REQ-QA-010 | Julia ≥ 1.10 compat bounds in Project.toml | ✅ |
| REQ-QA-011 | Julia General Registry + semver | 🔧 semver ✅, registry ⬜ |
| REQ-PKG-001 | Package structure (core + sub-packages) | 🔧 core only |
| REQ-PKG-002 | ≤ 10 direct dependencies | ✅ (4 deps) |
| REQ-PKG-003 | Package extensions for Colors, Unitful, Tables, Observables | ✅ |

**Phase 1 status: ~90% complete**

---

## Phase 2 — Idiomatic API

> Attribute aliases, theming, JS function bridge, file export, and initial documentation.

| Requirement | Description | Status |
|---|---|---|
| REQ-API-010 | Plots.jl-compatible attribute aliases | ✅ |
| REQ-API-011 | Colors.jl color type conversion | ✅ |
| REQ-API-020 | Theming system (`set_theme!`, `with_theme`) | ✅ |
| REQ-API-021 | Three built-in themes (default, dark, publication) | ✅ |
| REQ-API-022 | Custom themes from TOML/JSON files | ✅ |
| REQ-JSF-001 | `@jsf` macro for Julia → JS transpilation | ✅ |
| REQ-JSF-002 | Descriptive error on unsupported Julia constructs | ✅ |
| REQ-JSF-003 | MathJS integration (optional) | ⬜ |
| REQ-ECO-010 | `save(filename, board)` for HTML export | ✅ |
| REQ-DOC-001 | Documenter.jl site with tutorial + API reference | ✅ |

**Phase 2 status: ~80% complete**

---

## Phase 3 — Ecosystem

> Data ingestion, advanced constructions, recipe system, and convenience API.

| Requirement | Description | Status |
|---|---|---|
| REQ-GEO-004 | Composition/transformation elements (9 constructors) | ✅ |
| REQ-GEO-010 | Typed elements recording params, attrs, deps | ✅ |
| REQ-GEO-011 | Geometric dependency chains in generated JS | ✅ |
| REQ-GEO-012 | `@jsf` transitive dependency resolution | ✅ |
| REQ-API-002 | `scatter`, `parametric`, `implicit`, `polar` convenience | ✅ |
| REQ-API-004 | `do`-block syntax for board construction | ✅ |
| REQ-ECO-001 | Tables.jl data ingestion | ✅ |
| REQ-ECO-002 | Unitful.jl axis labels + unit conversion | ✅ |
| REQ-ECO-020 | `@jsxrecipe` recipe system | ✅ |
| REQ-ECO-021 | Recipe dispatch for custom types | ✅ |

**Phase 3 status: ~60% complete**

---

## Phase 4 — Polish & Interactivity

> Real-time interactivity, documentation gallery, CI hardening, performance, and export formats.

| Requirement | Description | Status |
|---|---|---|
| REQ-INT-001 | Client-side interactivity (sliders, draggable points) | ✅ |
| REQ-INT-002 | Dependent elements update in real time | ✅ |
| REQ-INT-010 | WebSocket bidirectional communication (optional) | ⬜ |
| REQ-INT-011 | Observables.jl live updates (optional) | ⬜ |
| REQ-DOC-002 | Gallery with 30+ categorized examples | ⬜ |
| REQ-DOC-003 | Live interactive rendering in docs | ⬜ |
| REQ-QA-001 | ≥ 80% code coverage in CI | ⬜ |
| REQ-QA-002 | HTML snapshot tests | ⬜ |
| REQ-QA-003 | CI pipeline: tests + lint + docs on PR | ⬜ |
| REQ-ECO-011 | SVG export via `save(*.svg)` | ⬜ |
| REQ-ECO-012 | PNG/PDF export via headless browser | ⬜ |
| REQ-PERF-001 | `using JSXGraph` under 1 second | ⬜ needs measurement |
| REQ-PERF-002 | 100-element board HTML in < 50 ms | ⬜ needs measurement |
| REQ-PERF-003 | Warning when HTML > 1 MB (excl. library assets) | ⬜ |

**Phase 4 status: ~15% complete**

---

## Cross-Cutting Requirements

| Requirement | Description | Status |
|---|---|---|
| REQ-NF-001 | MIT license | ✅ |
| REQ-NF-002 | CONTRIBUTING.md + issue templates | ✅ |
| REQ-NF-003 | CHANGELOG.md (Keep a Changelog) | ✅ |
| REQ-NF-004 | Docstrings with DocStringExtensions.jl | 🔧 partial |
| REQ-QA-012 | Declared JSXGraph version + update mechanism | ✅ |

---

## Suggested Next Priorities

1. ~~`save()` function~~ (REQ-ECO-010) ✅
2. ~~`@jsf` macro~~ (REQ-JSF-001/002) ✅
3. ~~Theming system~~ (REQ-API-020/021/022) ✅
4. ~~Convenience functions~~ (REQ-API-002) ✅
5. **`do`-block syntax** (REQ-API-004) — idiomatic board construction
6. **General Registry registration** (REQ-QA-011) — make the package installable with `Pkg.add`
7. **Documentation gallery** (REQ-DOC-002/003) — 30+ interactive examples
8. **CI coverage reporting** (REQ-QA-001/003) — GitHub Actions + Codecov

---

## Version Targets

| Version | Milestone | Key Deliverables |
|---|---|---|
| **0.6.0** | Export & `@jsf` | `save()`, `@jsf` macro, HTML snapshot tests |
| **0.7.0** | Theming | `set_theme!`, `with_theme`, 3 built-in themes |
| **0.8.0** | Convenience API | `scatter`, `parametric`, `implicit`, `polar`, `do`-block |
| **0.9.0** | Ecosystem | Tables.jl ingestion, Unitful.jl labels, recipe system |
| **1.0.0** | Stable release | General Registry, full docs gallery, ≥ 80% coverage |
