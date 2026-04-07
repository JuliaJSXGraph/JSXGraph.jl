module JSXGraphDefaultApplicationExt

using JSXGraph
using DefaultApplication

"""
    JSXGraph.open_in_browser(board::Board; asset_mode::Symbol=:inline) → String

Open a Board visualization in the default web browser.

Creates a temporary HTML file and opens it using the system's default browser.
Returns the path to the temporary file.
"""
function JSXGraph.open_in_browser(board::Board; asset_mode::Symbol=:inline)::String
    filename = tempname() * ".html"
    open(filename, "w") do io
        write(io, html_page(board; asset_mode=asset_mode))
    end
    DefaultApplication.open(filename)
    return filename
end

end
