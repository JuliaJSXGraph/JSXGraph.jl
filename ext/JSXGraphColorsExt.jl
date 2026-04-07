module JSXGraphColorsExt

using JSXGraph
using Colors

"""
    JSXGraph.color_to_css(c::Colorant) -> String

Convert a Colors.jl color value to a CSS color string.

For opaque colors (alpha == 1.0), returns a hex string like `"#FF0000"`.
For transparent colors, returns an rgba string like `"rgba(255,0,0,0.5)"`.
"""
function JSXGraph.color_to_css(c::Colorant)
    rgb = convert(RGBA, c)
    r = round(Int, red(rgb) * 255)
    g = round(Int, green(rgb) * 255)
    b = round(Int, blue(rgb) * 255)
    a = alpha(rgb)
    if a == 1.0
        return "#" * uppercase(
            string(r; base=16, pad=2) *
            string(g; base=16, pad=2) *
            string(b; base=16, pad=2),
        )
    else
        return "rgba($r,$g,$b,$(round(a; digits=4)))"
    end
end

end # module JSXGraphColorsExt
