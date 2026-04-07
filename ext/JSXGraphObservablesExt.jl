module JSXGraphObservablesExt

using JSXGraph
using Observables

"""
    JSXGraph.resolve_value(x::Observable) -> Any

Unwrap an `Observable` to its current value for rendering.

When Observables.jl is loaded, `Observable` values used as element parents
or attributes are automatically unwrapped at render time. In reactive
environments like Pluto.jl, mutating the observable triggers cell
re-execution, which regenerates the board with updated values.
"""
JSXGraph.resolve_value(x::Observable) = x[]

end # module JSXGraphObservablesExt
