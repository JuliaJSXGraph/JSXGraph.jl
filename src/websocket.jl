# WebSocket bidirectional communication stubs
# Real implementations provided by ext/JSXGraphHTTPExt.jl when HTTP.jl is loaded

using DocStringExtensions

const _WEBSOCKET_ERROR_MSG = """
WebSocket features require HTTP.jl. Install and load it with:
  using Pkg; Pkg.add("HTTP")
  using HTTP
"""

"""
$(TYPEDEF)

A board with an active WebSocket server for bidirectional communication.

Wraps a [`Board`](@ref) with server state, registered callbacks, and
connected browser client tracking.

$(TYPEDFIELDS)
"""
mutable struct LiveBoard
    "The underlying JSXGraph board"
    board::Board
    "The localhost port the server is bound to"
    port::Int
    "Whether the server is currently running"
    is_serving::Bool
    "Internal state (managed by extension)"
    _state::Any
end

"""
$(SIGNATURES)

Start a local WebSocket server for the given board and open it in the default browser.

Returns a [`LiveBoard`](@ref) with an active server connection.
Port 0 means OS-assigned (returned in `liveboard.port`).

# Keyword arguments
- `port::Int=0`: TCP port to listen on (0 = OS-assigned).
- `open_browser::Bool`: whether to open the board in the default browser.
  Defaults to `true` unless the `CI` environment variable is set.

Requires `HTTP.jl` to be loaded; throws an error otherwise.
"""
function serve end

"""
$(SIGNATURES)

Stop the WebSocket server and clean up all resources.

Closes all WebSocket connections, releases the TCP port, and cancels
the background server task. Safe to call multiple times.
"""
function stop_server! end

"""
$(SIGNATURES)

Register a callback for a specific element event on a live board.

Supported events: `:drag`, `:change`, `:click`.

The handler receives a `Dict{String,Any}` with event-specific fields:
- `:drag` → `data["x"]`, `data["y"]`
- `:change` → `data["value"]`
- `:click` → `data["x"]`, `data["y"]`

Multiple handlers per element/event are supported.
"""
function on end

"""
$(SIGNATURES)

Remove all callbacks for a specific element event on a live board.
"""
function off end

"""
$(SIGNATURES)

Push element property updates to all connected browsers.

Keyword arguments map to JSXGraph methods:
- `x`, `y` → calls `moveTo([x, y])` on the element
- Any other keyword → calls `setAttribute({key: value})`

Changes are sent to all connected browsers immediately.
"""
function update! end

# Stub: throws informative error when HTTP.jl is not loaded
# Uses a different signature (varargs) to avoid method overwrite conflicts with the extension
serve(args...; kwargs...) = error(_WEBSOCKET_ERROR_MSG)
stop_server!(args...) = error(_WEBSOCKET_ERROR_MSG)
on(args...) = error(_WEBSOCKET_ERROR_MSG)
off(args...) = error(_WEBSOCKET_ERROR_MSG)
update!(args...; kwargs...) = error(_WEBSOCKET_ERROR_MSG)
