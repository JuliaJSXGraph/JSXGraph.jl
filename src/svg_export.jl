"""
Export support for JSXGraph boards (REQ-ECO-011, REQ-ECO-012).

Supported formats: SVG, PNG, PDF.

The actual implementations live in `ext/JSXGraphNodeJSExt.jl` and are loaded
automatically when `NodeJS_22_jll` is available. The core module provides
the script generation utilities and stub functions that error with
instructions when the extension is not loaded.
"""

"""
    _NODE_MODULES_DIR

Directory where Node.js dependencies (jsdom) are installed for SVG export.
"""
const _NODE_MODULES_DIR = Ref{String}("")

function _node_modules_dir()
    if isempty(_NODE_MODULES_DIR[])
        _NODE_MODULES_DIR[] = joinpath(dirname(dirname(@__FILE__)), ".node_deps")
    end
    return _NODE_MODULES_DIR[]
end

"""
    _render_board_js_string(board::Board) -> String

Generate the JavaScript code for a board as a string (without HTML wrapping).
"""
function _render_board_js_string(board::Board)::String
    return sprint(render_board_js, board)
end

"""
    _board_dimensions(board::Board) -> (Int, Int)

Extract board width and height from options.
"""
function _board_dimensions(board::Board)
    opts = merge_with_defaults(board.options)
    css_opts = extract_css_options(opts)
    return (css_opts["width"], css_opts["height"])
end

"""
    _jsdom_board_preamble(board::Board) -> String

Generate the common Node.js preamble that sets up jsdom, injects JSXGraph,
and initializes the board. Shared by SVG, PNG, and PDF export scripts.
"""
function _jsdom_board_preamble(board::Board)::String
    jsxgraph_code = jsxgraph_js()
    board_js = _render_board_js_string(board)
    w, h = _board_dimensions(board)

    return """
    const { JSDOM } = require('jsdom');

    const html = `<!DOCTYPE html><html><head></head><body>
    <div id="$(board.id)" style="width:$(w)px;height:$(h)px;"></div>
    </body></html>`;

    const dom = new JSDOM(html, {
        pretendToBeVisual: true,
        runScripts: 'dangerously',
        resources: 'usable',
    });

    const window = dom.window;
    const document = window.document;

    // Suppress console output from JSXGraph (goes to stderr instead)
    const origConsole = { ...console };
    console.log = (...args) => process.stderr.write(args.join(' ') + '\\n');
    console.warn = (...args) => process.stderr.write('WARN: ' + args.join(' ') + '\\n');
    console.error = (...args) => process.stderr.write('ERR: ' + args.join(' ') + '\\n');

    // Polyfill browser APIs that jsdom doesn't support
    if (!window.SVGElement) {
        window.SVGElement = window.Element;
    }
    if (!window.IntersectionObserver) {
        window.IntersectionObserver = class { observe() {} unobserve() {} disconnect() {} };
    }
    if (!window.matchMedia) {
        window.matchMedia = () => ({ matches: false, addListener: () => {}, removeListener: () => {} });
    }

    // Inject JSXGraph
    const scriptEl = document.createElement('script');
    scriptEl.textContent = $(JSON.json(jsxgraph_code));
    document.head.appendChild(scriptEl);

    // Inject board initialization
    const boardScript = document.createElement('script');
    boardScript.textContent = $(JSON.json(board_js));
    document.head.appendChild(boardScript);
    """
end

"""
    _svg_extraction_js(board::Board) -> String

Generate JavaScript code that extracts the SVG element from the board
container and sets proper XML namespaces. The result is available as
`svgString` in the generated script.
"""
function _svg_extraction_js(board::Board)::String
    w, h = _board_dimensions(board)

    return """
        const container = document.getElementById('$(board.id)');
        if (!container) {
            process.stderr.write('ERROR: Board container not found\\n');
            process.exit(1);
        }
        const svg = container.querySelector('svg');
        if (!svg) {
            process.stderr.write('ERROR: No SVG element found in board\\n');
            process.exit(1);
        }

        // Add XML namespace and viewBox if missing
        svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
        svg.setAttribute('xmlns:xlink', 'http://www.w3.org/1999/xlink');
        if (!svg.getAttribute('viewBox')) {
            svg.setAttribute('viewBox', '0 0 $(w) $(h)');
        }

        const svgString = svg.outerHTML;
    """
end

"""
    _svg_export_script(board::Board) -> String

Generate a Node.js script that renders the board headlessly and prints the SVG to stdout.
"""
function _svg_export_script(board::Board)::String
    return _jsdom_board_preamble(board) * """

    // Extract SVG
    setTimeout(() => {
    $(_svg_extraction_js(board))
        // Output standalone SVG
        const fullSvg = '<?xml version="1.0" encoding="UTF-8"?>\\n' + svgString;
        process.stdout.write(fullSvg);
        process.exit(0);
    }, 100);
    """
end

"""
    _png_export_script(board::Board, output_path::String; scale::Int=1) -> String

Generate a Node.js script that renders the board headlessly to a PNG file.
Uses `sharp` for SVG → PNG conversion.
"""
function _png_export_script(board::Board, output_path::String; scale::Int=1)::String
    w, h = _board_dimensions(board)
    return _jsdom_board_preamble(board) * """

    const sharp = require('sharp');

    // Extract SVG and convert to PNG
    setTimeout(async () => {
        try {
    $(_svg_extraction_js(board))
            await sharp(Buffer.from(svgString))
                .resize($(w * scale), $(h * scale))
                .png()
                .toFile($(JSON.json(output_path)));

            process.exit(0);
        } catch (err) {
            process.stderr.write('ERROR: ' + err.message + '\\n');
            process.exit(1);
        }
    }, 100);
    """
end

"""
    _pdf_export_script(board::Board, output_path::String) -> String

Generate a Node.js script that renders the board headlessly to a PDF file.
Uses `pdfkit` + `svg-to-pdfkit` for SVG → PDF conversion.
"""
function _pdf_export_script(board::Board, output_path::String)::String
    w, h = _board_dimensions(board)
    return _jsdom_board_preamble(board) * """

    const PDFDocument = require('pdfkit');
    const SVGtoPDF = require('svg-to-pdfkit');
    const fs = require('fs');

    // Extract SVG and convert to PDF
    setTimeout(() => {
        try {
    $(_svg_extraction_js(board))
            const doc = new PDFDocument({ size: [$(w), $(h)], margin: 0 });
            const stream = fs.createWriteStream($(JSON.json(output_path)));
            doc.pipe(stream);
            SVGtoPDF(doc, svgString, 0, 0, { width: $(w), height: $(h) });
            doc.end();

            stream.on('finish', () => process.exit(0));
            stream.on('error', (err) => {
                process.stderr.write('ERROR: ' + err.message + '\\n');
                process.exit(1);
            });
        } catch (err) {
            process.stderr.write('ERROR: ' + err.message + '\\n');
            process.exit(1);
        }
    }, 100);
    """
end

"""
    save_svg(filename::String, board::Board)

Export a board as a static SVG image file.

Requires `NodeJS_22_jll` to be installed. Add it with:

```julia
using Pkg; Pkg.add("NodeJS_22_jll")
```

Then load it before calling `save_svg`:

```julia
using NodeJS_22_jll
save("plot.svg", board)
```

# Arguments
- `filename::String`: Output file path (should end in `.svg`)
- `board::Board`: The board to export
"""
function save_svg end

"""
    save_png(filename::String, board::Board; scale::Int=1)

Export a board as a PNG image file.

The `scale` parameter controls the resolution multiplier (e.g. `scale=2`
produces a 2× resolution image suitable for Retina/HiDPI displays).

Requires `NodeJS_22_jll` to be installed. Add it with:

```julia
using Pkg; Pkg.add("NodeJS_22_jll")
```

Then load it before calling `save_png`:

```julia
using NodeJS_22_jll
save("plot.png", board)
save("plot_hd.png", board; scale=2)  # 2× resolution
```

# Arguments
- `filename::String`: Output file path (should end in `.png`)
- `board::Board`: The board to export
- `scale::Int=1`: Resolution multiplier (1 = native, 2 = 2× Retina)
"""
function save_png end

"""
    save_pdf(filename::String, board::Board)

Export a board as a PDF document.

Requires `NodeJS_22_jll` to be installed. Add it with:

```julia
using Pkg; Pkg.add("NodeJS_22_jll")
```

Then load it before calling `save_pdf`:

```julia
using NodeJS_22_jll
save("plot.pdf", board)
```

# Arguments
- `filename::String`: Output file path (should end in `.pdf`)
- `board::Board`: The board to export
"""
function save_pdf end
