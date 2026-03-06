"""
$(SIGNATURES)

Write JSXGraph library assets to `io`.

When `mode` is `:inline`, embeds the full JS and CSS content.
When `mode` is `:cdn`, writes `<link>` and `<script src="...">` tags referencing the jsdelivr CDN.

The `css_only` flag (default `false`) can be set to `true` to emit only the CSS
stylesheet — useful in fragment mode where the JS library is loaded via a
RequireJS-compatible script loader.
"""
function render_assets(io::IO; mode::Symbol=:inline, css_only::Bool=false)
    if mode == :inline
        print(io, "<style>\n")
        print(io, jsxgraph_css())
        print(io, "\n</style>\n")
        if !css_only
            print(io, "<script>\n")
            print(io, jsxgraph_js())
            print(io, "\n</script>\n")
        end
    elseif mode == :cdn
        print(
            io,
            "<link rel=\"stylesheet\" type=\"text/css\" href=\"$(JSXGRAPH_CDN_CSS)\" />\n",
        )
        if !css_only
            print(io, "<script type=\"text/javascript\" src=\"$(JSXGRAPH_CDN_JS)\"></script>\n")
        end
    else
        throw(ArgumentError("asset_mode must be :inline or :cdn, got :$mode"))
    end
end

"""
$(SIGNATURES)

Write the JavaScript code that initializes a JSXGraph board to `io`.
"""
function render_board_js(io::IO, board::Board)
    board_var = replace(board.id, r"[^a-zA-Z0-9_]" => "_")
    js_options = board_options_to_js(merge_with_defaults(board.options))
    print(
        io,
        "var board_$(board_var) = JXG.JSXGraph.initBoard('$(board.id)', $(js_options));\n",
    )
    # Emit named JSFunction dependencies in topological order
    deps = collect_jsf_deps(board)
    for dep in deps
        # Convert anonymous function to named declaration:
        #   "function(x){...}"  →  "function square(x){...}"
        named_code = replace(dep.code, r"^function\(" => "function $(dep.name)("; count=1)
        print(io, named_code, "\n")
    end
    # Build element ID mapping for cross-references
    elem_ids = Dict{UInt64,String}()
    for (i, elem) in enumerate(board.elements)
        var_name = "el_" * lpad(i, 3, '0')
        elem_ids[objectid(elem)] = var_name
    end
    # Render each element
    for (i, elem) in enumerate(board.elements)
        var_name = "el_" * lpad(i, 3, '0')
        parents_js = join([parent_to_js(p, elem_ids) for p in elem.parents], ",")
        attrs_js = attrs_to_js(elem.attributes)
        print(
            io,
            "var $(var_name) = board_$(board_var).create('$(elem.type_name)', [$(parents_js)], $(attrs_js));\n",
        )
    end
end

"""
CDN URL for the JSXGraph JavaScript library (minified, for RequireJS compatibility).
"""
const JSXGRAPH_CDN_JS_MIN = "https://cdn.jsdelivr.net/npm/jsxgraph@$(JSXGRAPH_VERSION)/distrib/jsxgraphcore.min"

"""
$(SIGNATURES)

Write the HTML for a board to `io`.

When `full_page=true`, generates a complete HTML5 document.
When `full_page=false`, generates an embeddable HTML fragment.

In fragment mode (notebooks, Documenter.jl), the board initialization script
is wrapped in a loader that handles RequireJS environments (where the CDN
`<script>` tag registers JSXGraph as an AMD module instead of setting `JXG`
globally).
"""
function render_board_html(
    io::IO, board::Board; full_page::Bool=true, asset_mode::Symbol=:inline
)
    css_opts = extract_css_options(board.options)
    w = css_opts["width"]
    h = css_opts["height"]
    style_parts = ["width:$(w)px", "height:$(h)px"]
    if haskey(css_opts, "background")
        push!(style_parts, "background:$(css_opts["background"])")
    end
    style_str = join(style_parts, ";")

    if full_page
        # Full page: we control the <head>, no RequireJS conflict.
        print(io, "<!DOCTYPE html>\n")
        print(io, "<html>\n<head>\n")
        print(io, "<meta charset=\"UTF-8\">\n")
        print(io, "<title>JSXGraph Board</title>\n")
        render_assets(io; mode=asset_mode)
        print(io, "</head>\n<body>\n")
        print(io, "<div id=\"$(board.id)\" class=\"jxgbox\" style=\"$(style_str)\"></div>\n")
        print(io, "<script>\n")
        render_board_js(io, board)
        print(io, "</script>\n")
        print(io, "</body>\n</html>\n")
    else
        # Fragment mode.
        # Emit CSS only — JS is loaded dynamically to avoid conflicts with
        # RequireJS (e.g. Documenter.jl), which causes JSXGraph's UMD wrapper
        # to register as an AMD module instead of setting JXG globally.
        render_assets(io; mode=asset_mode, css_only=true)
        print(io, "<div id=\"$(board.id)\" class=\"jxgbox\" style=\"$(style_str)\"></div>\n")

        board_js = sprint(render_board_js, board)
        escaped_js = replace(board_js, "\\" => "\\\\", "'" => "\\'", "\n" => "\\n")

        if asset_mode == :inline
            # Inline: embed the full library source with AMD detection disabled,
            # so JXG is set globally even when RequireJS is present.
            print(io, "<script>\n")
            print(io, "(function(){\n")
            print(io, "if(typeof JXG==='undefined'){\n")
            print(io, "var _sd=window.define;window.define=undefined;\n")
            print(io, jsxgraph_js())
            print(io, "\nwindow.define=_sd;\n")
            print(io, "}\n")
            print(io, "})();\n")
            print(io, "</script>\n")
            print(io, "<script>\n")
            render_board_js(io, board)
            print(io, "</script>\n")
        else
            # CDN: use a RequireJS-compatible loader that handles three scenarios:
            # 1. JXG globally available → use it directly
            # 2. RequireJS present (Documenter.jl) → load via require()
            # 3. Neither → create a <script> tag dynamically
            print(io, """<script>
(function() {
  var boardCode = '$(escaped_js)';
  function runBoard() { try { eval(boardCode); } catch(ex) { console.error('JSXGraph board error:', ex); } }
  if (typeof JXG !== 'undefined') {
    runBoard();
  } else if (typeof require !== 'undefined') {
    require.config({paths:{'jsxgraph':'$(JSXGRAPH_CDN_JS_MIN)'}});
    require(['jsxgraph'], function(JXG) { window.JXG = JXG; runBoard(); });
  } else {
    var s = document.createElement('script');
    s.src = '$(JSXGRAPH_CDN_JS)';
    s.onload = runBoard;
    document.head.appendChild(s);
  }
})();
</script>
""")
        end
    end
end

"""
$(SIGNATURES)

Generate an HTML string for a board.

# Arguments
- `board::Board`: The board to render
- `full_page::Bool=true`: Generate a complete HTML document (`true`) or embeddable fragment (`false`)
- `asset_mode::Symbol=:inline`: `:inline` embeds JS/CSS; `:cdn` references CDN URLs

# Examples
```julia
board = Board("myboard", xlim=(-5,5), ylim=(-5,5))
html = html_string(board)                          # full page, inline assets
html = html_string(board; full_page=false)          # fragment
html = html_string(board; asset_mode=:cdn)          # CDN references
```
"""
function html_string(board::Board; full_page::Bool=true, asset_mode::Symbol=:inline)::String
    html = sprint() do io
        render_board_html(io, board; full_page=full_page, asset_mode=asset_mode)
    end
    _check_html_size(html, board, asset_mode)
    return html
end

"""
$(SIGNATURES)

Generate a complete HTML page for a board.

Equivalent to `html_string(board; full_page=true, kwargs...)`.
"""
function html_page(board::Board; kwargs...)::String
    return html_string(board; full_page=true, kwargs...)
end

"""
$(SIGNATURES)

Generate an HTML fragment for a board (no DOCTYPE/head/body).

Equivalent to `html_string(board; full_page=false, kwargs...)`.
"""
function html_fragment(board::Board; kwargs...)::String
    return html_string(board; full_page=false, kwargs...)
end

"""
$(SIGNATURES)

Save a board to a file.

Dispatches on the file extension:
- `.html` (default): writes a self-contained HTML document
- `.svg`: exports a static SVG image (requires NodeJS_22_jll)
- `.png`: exports a PNG image (requires NodeJS_22_jll)
- `.pdf`: exports a PDF document (requires NodeJS_22_jll)

# Arguments
- `filename::String`: Output file path (`.html`, `.svg`, `.png`, `.pdf`)
- `board::Board`: The board to save
- `asset_mode::Symbol=:inline`: for HTML output — `:inline` embeds JS/CSS; `:cdn` references CDN URLs
- `scale::Int=1`: for PNG output — resolution multiplier (1 = native, 2 = Retina)

# Examples
```julia
board = Board("myboard", xlim=(-5,5), ylim=(-5,5))
push!(board, point(1, 2))
save("plot.html", board)
save("plot_cdn.html", board; asset_mode=:cdn)
save("plot.svg", board)
save("plot.png", board)           # PNG export
save("plot_hd.png", board; scale=2) # 2× resolution PNG
save("plot.pdf", board)           # PDF export
```
"""
function save(filename::String, board::Board; asset_mode::Symbol=:inline, scale::Int=1)
    ext = lowercase(splitext(filename)[2])
    if ext == ".svg"
        _require_nodejs_ext("SVG")
        return save_svg(filename, board)
    elseif ext == ".png"
        _require_nodejs_ext("PNG")
        return save_png(filename, board; scale=scale)
    elseif ext == ".pdf"
        _require_nodejs_ext("PDF")
        return save_pdf(filename, board)
    elseif ext == ".html" || ext == ".htm"
        html = html_string(board; full_page=true, asset_mode=asset_mode)
        open(filename, "w") do io
            write(io, html)
        end
        return filename
    else
        error(
            "Unsupported file extension '$ext'. " *
            "Supported formats: .html, .svg, .png, .pdf"
        )
    end
end

"""
    _require_nodejs_ext(format::String)

Check that the NodeJS extension is loaded. Throws an informative error if not.
"""
function _require_nodejs_ext(format::String)
    if !hasmethod(save_svg, Tuple{String, Board})
        error(
            "$(format) export requires the NodeJS_22_jll package.\n" *
            "Install and load it with:\n" *
            "  using Pkg; Pkg.add(\"NodeJS_22_jll\")\n" *
            "  using NodeJS_22_jll"
        )
    end
end

"""
    HTML_SIZE_THRESHOLD

Maximum content size (in bytes) for generated HTML, excluding inlined JSXGraph library
assets. If the content exceeds this threshold, a warning is emitted suggesting the user
reduce element count or switch to CDN-based asset loading.

Default: 1 MB (1_048_576 bytes).
"""
const HTML_SIZE_THRESHOLD = 1_048_576

"""
    _asset_overhead() -> Int

Estimate the byte size of the inlined JSXGraph library assets (JS + CSS + wrapper tags).
"""
function _asset_overhead()::Int
    return length(jsxgraph_js()) + length(jsxgraph_css()) +
           length("<style>\n\n</style>\n<script>\n\n</script>\n")
end

"""
    _check_html_size(html, board, asset_mode)

Emit a warning if the generated HTML content (excluding library assets) exceeds
[`HTML_SIZE_THRESHOLD`](@ref) (REQ-PERF-003).
"""
function _check_html_size(html::String, board::Board, asset_mode::Symbol)
    content_size = if asset_mode == :inline
        length(html) - _asset_overhead()
    else
        length(html)
    end
    if content_size > HTML_SIZE_THRESHOLD
        size_mb = round(content_size / 1_048_576; digits=2)
        @warn(
            "Generated HTML content is $(size_mb) MB (excluding library assets), " *
            "which exceeds the 1 MB threshold. Consider reducing the number of elements " *
            "or switching to CDN-based asset loading (asset_mode=:cdn).",
            board_id = board.id,
            element_count = length(board.elements),
        )
    end
    return nothing
end
