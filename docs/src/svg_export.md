# Static Export (SVG, PNG, PDF)

JSXGraph.jl supports exporting boards as static images via `save()` or the
direct export functions `save_svg()`, `save_png()`, `save_pdf()`.

## Requirements

Static export is provided via a **package extension** that depends on
[`NodeJS_22_jll`](https://github.com/JuliaBinaryWrappers/NodeJS_22_jll.jl).
Node.js v22 is automatically downloaded as a Julia artifact — no system
installation needed. On first export, required npm packages are
installed in a package-local directory (`.node_deps/`).

| Format | npm packages (auto-installed) |
|--------|-------------------------------|
| SVG    | `jsdom`                       |
| PNG    | `jsdom`, `sharp`              |
| PDF    | `jsdom`, `pdfkit`, `svg-to-pdfkit` |

```julia
using Pkg
Pkg.add("NodeJS_22_jll")
```

## Usage

### Export via `save()`

Load `NodeJS_22_jll`, then the `save()` function dispatches on the file extension:

```julia
using JSXGraph
using NodeJS_22_jll  # activates static export extension

b = board("myboard", xlim=(-5, 5), ylim=(-5, 5)) do
    point(1, 2; name="A")
    circle(point(0, 0), 3; strokeColor="blue")
end

# HTML export (always available)
save("plot.html", b)

# SVG export
save("plot.svg", b)

# PNG export
save("plot.png", b)

# PNG with 2× resolution (Retina/HiDPI)
save("plot_hd.png", b; scale=2)

# PDF export
save("plot.pdf", b)
```

### Direct export functions

```julia
save_svg("plot.svg", b)
save_png("plot.png", b)
save_png("plot_hd.png", b; scale=2)
save_pdf("plot.pdf", b)
```

## Supported Formats

| Extension | Format | Backend |
|-----------|--------|---------|
| `.html`   | Self-contained HTML page | Built-in |
| `.svg`    | Scalable Vector Graphics | NodeJS_22_jll + jsdom |
| `.png`    | Portable Network Graphics | NodeJS_22_jll + jsdom + sharp |
| `.pdf`    | PDF document | NodeJS_22_jll + jsdom + pdfkit + svg-to-pdfkit |

Unsupported extensions (e.g. `.gif`, `.bmp`) raise an `ErrorException`.

## Scale Factor (PNG)

The `scale` keyword controls the output resolution for PNG exports:

```julia
save("plot.png", board; scale=1)  # native resolution (e.g. 500×500)
save("plot.png", board; scale=2)  # 2× resolution (e.g. 1000×1000)
save("plot.png", board; scale=3)  # 3× resolution (e.g. 1500×1500)
```

Higher scale values produce sharper images suitable for print or HiDPI displays.

## API Reference

```@docs
save_svg
save_png
save_pdf
```

## How It Works

1. A Node.js script is generated that creates a virtual DOM using jsdom
2. The JSXGraph library is injected into the virtual DOM
3. The board is initialized with all elements
4. The SVG element is extracted from the DOM
5. For SVG: the raw SVG is written with proper XML headers
6. For PNG: `sharp` converts the SVG to a raster image at the specified scale
7. For PDF: `pdfkit` + `svg-to-pdfkit` embed the SVG in a PDF document

Node.js is provided by `NodeJS_22_jll` (Julia artifact, no system dependency).

## Troubleshooting

**"SVG/PNG/PDF export requires the NodeJS_22_jll package"**: Load it first:
```julia
using NodeJS_22_jll
```

**npm package installation fails**: Try installing manually:
```sh
cd ~/.julia/packages/JSXGraph/<hash>/.node_deps
~/.julia/artifacts/<nodejs_hash>/bin/npm install jsdom sharp pdfkit svg-to-pdfkit
```
