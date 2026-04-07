"""
Version of the bundled JSXGraph JavaScript library.
"""
const JSXGRAPH_VERSION = "1.12.2"

"""
CDN URL for the JSXGraph JavaScript library (version-pinned via jsdelivr).
"""
const JSXGRAPH_CDN_JS = "https://cdn.jsdelivr.net/npm/jsxgraph@$(JSXGRAPH_VERSION)/distrib/jsxgraphcore.js"

"""
CDN URL for the JSXGraph CSS stylesheet (version-pinned via jsdelivr).
"""
const JSXGRAPH_CDN_CSS = "https://cdn.jsdelivr.net/npm/jsxgraph@$(JSXGRAPH_VERSION)/distrib/jsxgraph.css"

const _JSXGRAPH_JS_CACHE = Ref{String}("")
const _JSXGRAPH_CSS_CACHE = Ref{String}("")

"""
$(SIGNATURES)

Return the contents of the bundled `jsxgraphcore.js` file as a string.

The file is read from the Julia Artifacts system on first call and cached
for subsequent calls.
"""
function jsxgraph_js()::String
    if isempty(_JSXGRAPH_JS_CACHE[])
        artifact_dir = artifact"jsxgraph"
        path = joinpath(artifact_dir, "jsxgraphcore.js")
        if !isfile(path)
            error(
                "JSXGraph artifact file not found at $path. " *
                "Try reinstalling the package with `Pkg.rm(\"JSXGraph\"); Pkg.add(\"JSXGraph\")`.",
            )
        end
        _JSXGRAPH_JS_CACHE[] = read(path, String)
    end
    return _JSXGRAPH_JS_CACHE[]
end

"""
$(SIGNATURES)

Return the contents of the bundled `jsxgraph.css` file as a string.

The file is read from the Julia Artifacts system on first call and cached
for subsequent calls.
"""
function jsxgraph_css()::String
    if isempty(_JSXGRAPH_CSS_CACHE[])
        artifact_dir = artifact"jsxgraph"
        path = joinpath(artifact_dir, "jsxgraph.css")
        if !isfile(path)
            error(
                "JSXGraph artifact file not found at $path. " *
                "Try reinstalling the package with `Pkg.rm(\"JSXGraph\"); Pkg.add(\"JSXGraph\")`.",
            )
        end
        _JSXGRAPH_CSS_CACHE[] = read(path, String)
    end
    return _JSXGRAPH_CSS_CACHE[]
end
