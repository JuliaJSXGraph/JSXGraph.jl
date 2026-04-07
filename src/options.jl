"""
Default board options applied when creating a new Board.
"""
const DEFAULT_BOARD_OPTIONS = Dict{String,Any}(
    "axis" => true,
    "showNavigation" => false,
    "showCopyright" => false,
    "boundingbox" => [-5, 5, 5, -5],
)

"""
Option keys that are applied as CSS on the div container, not passed to `JXG.JSXGraph.initBoard`.
"""
const CSS_OPTION_KEYS = Set(["width", "height", "background"])

"""
$(SIGNATURES)

Merge user-provided options over the default board options.
"""
function merge_with_defaults(options::Dict{String,Any})::Dict{String,Any}
    return merge(DEFAULT_BOARD_OPTIONS, options)
end

"""
$(SIGNATURES)

Convert a board options dictionary to a JSON string for use in `JXG.JSXGraph.initBoard`.

CSS-only keys (`width`, `height`, `background`) are filtered out.
All other keys are passed through to the JavaScript object.
"""
function board_options_to_js(options::Dict{String,Any})::String
    js_options = Dict{String,Any}()
    for (k, v) in options
        if k ∉ CSS_OPTION_KEYS
            js_options[k] = v
        end
    end
    return sorted_json(js_options)
end

"""
$(SIGNATURES)

Extract CSS-only options from the board options dictionary.

Returns a dictionary containing only `width`, `height`, and `background` keys
(with defaults of 500, 500, and no background if not specified).
"""
function extract_css_options(options::Dict{String,Any})::Dict{String,Any}
    css = Dict{String,Any}()
    for k in CSS_OPTION_KEYS
        if haskey(options, k)
            css[k] = options[k]
        end
    end
    # Apply defaults for width and height if not specified
    if !haskey(css, "width")
        css["width"] = 500
    end
    if !haskey(css, "height")
        css["height"] = 500
    end
    return css
end
