# Display protocol: Base.show methods for Board objects

"""
    open_in_browser(board::Board; asset_mode::Symbol=:inline) → String

Open a Board visualization in the default web browser.

Requires the `DefaultApplication.jl` package to be installed and loaded.
"""
function open_in_browser end

"""
$(SIGNATURES)

Display a Board as an HTML fragment for notebook environments (Jupyter, Pluto, VS Code).

Generates a unique display ID per call to avoid DOM conflicts when multiple cells
render the same board. Uses CDN mode for compact output.
"""
function Base.show(io::IO, ::MIME"text/html", board::Board)
    display_id = "jxg_" * randstring(12)
    display_board = Board(display_id, board.elements, board.options)
    render_board_html(io, display_board; full_page=false, asset_mode=:cdn)
end

"""
$(SIGNATURES)

Display a compact text summary of a Board in the REPL.

Format: `Board("id", N elements, x=[xmin,xmax], y=[ymin,ymax], WxHpx)`
"""
function Base.show(io::IO, ::MIME"text/plain", board::Board)
    n = length(board.elements)
    elem_str = n == 1 ? "1 element" : "$(n) elements"

    bb = get(board.options, "boundingbox", [-5, 5, 5, -5])
    xmin, ymax, xmax, ymin = bb

    css = extract_css_options(board.options)
    w = css["width"]
    h = css["height"]

    print(
        io,
        "Board(\"$(board.id)\", $(elem_str), x=[$(xmin),$(xmax)], y=[$(ymin),$(ymax)], $(w)x$(h)px)",
    )
end
