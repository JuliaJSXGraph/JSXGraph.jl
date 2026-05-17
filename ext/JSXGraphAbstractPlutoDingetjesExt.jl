module JSXGraphAbstractPlutoDingetjesExt

using JSXGraph
using JSON
using AbstractPlutoDingetjes

# Register the Pluto-aware seed-data publisher when this extension
# loads (Pluto loads `AbstractPlutoDingetjes` automatically). The
# publisher routes through `Display.published_to_js` when the IO
# context supports it (i.e. a real Pluto session); everywhere else it
# falls back to JSON inline, honouring FR-008 (non-Pluto hosts must
# render without errors).
function __init__()
    JSXGraph._SEED_PUBLISHER[] = _pluto_publish
end

function _pluto_publish(io::IO, data)
    if AbstractPlutoDingetjes.is_supported_by_display(
        io, AbstractPlutoDingetjes.Display.published_to_js
    )
        pub = AbstractPlutoDingetjes.Display.published_to_js(data)
        show(io, MIME("text/javascript"), pub)
    else
        JSON.print(io, data)
    end
    return nothing
end

# Pluto evaluates dependent cells on first render BEFORE the browser
# has dispatched the initial `input` event. Without an `initial_value`
# method, `@bind state ...` yields `missing`/`nothing`, which breaks
# any downstream cell that calls `points_xy(state)` etc.
#
# Returning the seeded state here means `state` is already a meaningful
# `Dict{String,Any}` on first run, mirroring the JS-side seed publish.
function AbstractPlutoDingetjes.Bonds.initial_value(board::JSXGraph.Board)
    if get(board.options, "bindable", false) === true
        return JSXGraph._initial_bound_state(board)
    end
    return missing
end

end # module
