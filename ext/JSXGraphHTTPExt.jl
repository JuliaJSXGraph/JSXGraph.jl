module JSXGraphHTTPExt

using JSXGraph
using HTTP
using HTTP.WebSockets
using JSON
using Sockets: getsockname

# ── Internal state for a LiveBoard ──────────────────────────────────────────

mutable struct _ServerState
    server::Any  # HTTP.Server object
    connections::Set{Any}  # WebSocket connections
    callbacks::Dict{Tuple{String,Symbol},Vector{Function}}
    board_html::String
end

# ── Helper: build element ID map (same logic as render_board_js) ────────────

function _build_elem_ids(board::JSXGraph.Board)
    elem_ids = Dict{UInt64,String}()
    for (i, elem) in enumerate(board.elements)
        var_name = "el_" * lpad(i, 3, '0')
        elem_ids[objectid(elem)] = var_name
        if elem isa JSXGraph.View3D
            for (j, child) in enumerate(elem.elements)
                child_var = var_name * "_" * lpad(j, 3, '0')
                elem_ids[objectid(child)] = child_var
            end
        end
    end
    return elem_ids
end

function _get_element_id(board::JSXGraph.Board, elem::JSXGraph.AbstractJSXElement)
    elem_ids = _build_elem_ids(board)
    id = objectid(elem)
    haskey(elem_ids, id) || throw(ArgumentError("Element not found on this board"))
    return elem_ids[id]
end

# ── WebSocket client JavaScript ─────────────────────────────────────────────

function _websocket_client_js(port::Int, board_id::String, registered_elements::Dict{String,Set{Symbol}})
    listeners_js = IOBuffer()
    board_var = "board_" * replace(board_id, r"[^a-zA-Z0-9_]" => "_")

    for (elem_id, events) in registered_elements
        for event in events
            jsxevent = if event === :drag
                "drag"
            elseif event === :change
                "drag"  # sliders use drag event in JSXGraph
            elseif event === :click
                "down"
            else
                string(event)
            end

            data_js = if event === :drag || event === :click
                """{"x": $(elem_id).X(), "y": $(elem_id).Y()}"""
            elseif event === :change
                """{"value": $(elem_id).Value()}"""
            else
                "{}"
            end

            print(listeners_js, """
      $(elem_id).on('$(jsxevent)', (function() {
        var _lastSend = 0;
        return function() {
          var now = Date.now();
          if (now - _lastSend < 50) return;
          _lastSend = now;
          if (_jsxWs && _jsxWs.readyState === WebSocket.OPEN) {
            _jsxWs.send(JSON.stringify({
              "type": "event",
              "board_id": "$(board_id)",
              "element_id": "$(elem_id)",
              "event": "$(event)",
              "data": $(data_js)
            }));
          }
        };
      })());
""")
        end
    end

    return """
<script>
(function() {
  var _jsxWs = new WebSocket('ws://localhost:$(port)/ws');
  window._jsxWs = _jsxWs;

  _jsxWs.onopen = function() {
    console.log('JSXGraph WebSocket connected');
  };

  _jsxWs.onmessage = function(evt) {
    var msg = JSON.parse(evt.data);
    if (msg.type === 'ping') {
      _jsxWs.send(JSON.stringify({"type": "pong"}));
    } else if (msg.type === 'update') {
      var elem = window[msg.element_id];
      if (elem && elem[msg.method]) {
        elem[msg.method].apply(elem, msg.args);
        if (typeof $(board_var) !== 'undefined') $(board_var).update();
      }
    } else if (msg.type === 'error') {
      console.error('JSXGraph server error:', msg.message);
    }
  };

  _jsxWs.onclose = function() {
    console.log('JSXGraph WebSocket disconnected');
    var div = document.getElementById('$(board_id)');
    if (div) {
      var overlay = document.createElement('div');
      overlay.style.cssText = 'position:absolute;top:0;left:0;right:0;padding:4px;background:rgba(255,0,0,0.7);color:white;text-align:center;font-size:12px;z-index:9999;';
      overlay.textContent = 'Disconnected from Julia';
      div.style.position = 'relative';
      div.appendChild(overlay);
    }
  };

$(String(take!(listeners_js)))})();
</script>
"""
end

# ── Generate served HTML with WebSocket JS injected ─────────────────────────

function _generate_served_html(board::JSXGraph.Board, port::Int, registered_elements::Dict{String,Set{Symbol}})
    base_html = JSXGraph.html_page(board; asset_mode=:cdn)
    ws_js = _websocket_client_js(port, board.id, registered_elements)
    return replace(base_html, "</body>" => "$(ws_js)\n</body>")
end

# ── WebSocket message handler ───────────────────────────────────────────────

function _handle_ws_message(state::_ServerState, msg_str::String)
    local msg
    try
        msg = JSON.parse(msg_str)
    catch
        @warn "JSXGraph WebSocket: malformed JSON received"
        return nothing
    end

    msg_type = get(msg, "type", "")

    if msg_type == "pong"
        return nothing
    elseif msg_type == "event"
        element_id = get(msg, "element_id", "")
        event_str = get(msg, "event", "")
        data = get(msg, "data", Dict{String,Any}())

        if isempty(element_id) || isempty(event_str)
            @warn "JSXGraph WebSocket: event missing element_id or event type"
            return nothing
        end

        event = Symbol(event_str)
        key = (element_id, event)

        handlers = get(state.callbacks, key, Function[])
        if isempty(handlers)
            @warn "JSXGraph WebSocket: no handler for ($element_id, $event)"
            return nothing
        end

        for handler in handlers
            try
                handler(data)
            catch e
                @error "JSXGraph WebSocket: callback error" element_id event exception=(e, catch_backtrace())
                return Dict("type" => "error", "message" => "Callback error: $(sprint(showerror, e))")
            end
        end
    else
        @warn "JSXGraph WebSocket: unknown message type '$msg_type'"
    end

    return nothing
end

# ── Broadcast message to all connected browsers ────────────────────────────

function _broadcast(state::_ServerState, msg::Dict)
    json_msg = JSON.json(msg)
    stale = Set{Any}()
    conns = collect(state.connections)  # snapshot to avoid mutation during iteration
    for ws in conns
        try
            HTTP.WebSockets.send(ws, json_msg)
        catch
            push!(stale, ws)
        end
    end
    for ws in stale
        delete!(state.connections, ws)
    end
end

# ── serve() implementation ──────────────────────────────────────────────────

function JSXGraph.serve(board::JSXGraph.Board; port::Int=0, open_browser::Bool=!haskey(ENV, "CI"))
    state = _ServerState(
        nothing,
        Set{Any}(),
        Dict{Tuple{String,Symbol},Vector{Function}}(),
        ""
    )

    lb = JSXGraph.LiveBoard(board, 0, false, state)

    # Start non-blocking HTTP server with stream handler
    server = HTTP.listen!("127.0.0.1", port) do http
        req = http.message
        if HTTP.WebSockets.isupgrade(req)
            HTTP.WebSockets.upgrade(http) do ws
                push!(state.connections, ws)
                try
                    for msg in ws
                        response = _handle_ws_message(state, String(msg))
                        if response !== nothing
                            try
                                HTTP.WebSockets.send(ws, JSON.json(response))
                            catch
                                break
                            end
                        end
                    end
                catch e
                    if !(e isa EOFError)
                        @debug "JSXGraph WebSocket connection closed" exception=(e, catch_backtrace())
                    end
                finally
                    delete!(state.connections, ws)
                end
            end
        else
            target = req.target
            if target == "/" || target == "/index.html"
                req.response.status = 200
                HTTP.setheader(http, "Content-Type" => "text/html; charset=utf-8")
                startwrite(http)
                write(http, state.board_html)
            else
                req.response.status = 404
                HTTP.setheader(http, "Content-Type" => "text/plain")
                startwrite(http)
                write(http, "Not found")
            end
        end
    end

    state.server = server

    # Get actual bound port from the underlying TCPServer
    bound_port = Int(getsockname(server.listener.server)[2])
    lb.port = bound_port
    lb.is_serving = true

    # Generate HTML with correct port
    state.board_html = _generate_served_html(board, bound_port, Dict{String,Set{Symbol}}())

    @info "JSXGraph server listening on http://127.0.0.1:$(bound_port)"

    # Start heartbeat task
    @async begin
        while lb.is_serving
            try
                _broadcast(state, Dict("type" => "ping"))
            catch
            end
            sleep(30)
        end
    end

    # Try to open in browser
    if open_browser
        try
            _open_browser("http://127.0.0.1:$(lb.port)")
        catch e
            @warn "Could not open browser automatically" exception=e
        end
    end

    return lb
end

# ── Browser opening helper ──────────────────────────────────────────────────

function _open_browser(url::String)
    # Use DefaultApplication.jl if loaded (preferred cross-platform approach),
    # otherwise fall back to platform-specific commands (non-blocking)
    da_id = Base.PkgId(Base.UUID("3f0dd361-4fe0-5fc6-8523-80b14ec94d85"), "DefaultApplication")
    if haskey(Base.loaded_modules, da_id)
        Base.loaded_modules[da_id].open(url)
    elseif Sys.isapple()
        run(`open $url`; wait=false)
    elseif Sys.islinux()
        run(`xdg-open $url`; wait=false)
    elseif Sys.iswindows()
        run(`cmd /c start $url`; wait=false)
    end
end

# ── stop_server!() implementation ───────────────────────────────────────────

function JSXGraph.stop_server!(lb::JSXGraph.LiveBoard)
    if !lb.is_serving
        return nothing
    end

    state = lb._state::_ServerState
    lb.is_serving = false

    # Close all WebSocket connections
    for ws in copy(state.connections)
        try
            close(ws)
        catch
        end
    end
    empty!(state.connections)

    # Close the HTTP server
    if state.server !== nothing
        try
            close(state.server)
        catch
        end
    end

    @info "JSXGraph server stopped"
    return nothing
end

# ── on() implementation ─────────────────────────────────────────────────────

const _SUPPORTED_EVENTS = Set([:drag, :change, :click])

function JSXGraph.on(lb::JSXGraph.LiveBoard, elem::JSXGraph.AbstractJSXElement, event::Symbol, handler::Function)
    event in _SUPPORTED_EVENTS || throw(ArgumentError("Unsupported event type :$event. Supported: :drag, :change, :click"))

    state = lb._state::_ServerState
    elem_id = _get_element_id(lb.board, elem)
    key = (elem_id, event)

    if !haskey(state.callbacks, key)
        state.callbacks[key] = Function[]
    end
    push!(state.callbacks[key], handler)

    # Regenerate HTML with updated event listeners
    _regenerate_html!(lb)

    return nothing
end

# do-block syntax
function JSXGraph.on(handler::Function, lb::JSXGraph.LiveBoard, elem::JSXGraph.AbstractJSXElement, event::Symbol)
    return JSXGraph.on(lb, elem, event, handler)
end

# ── off() implementation ────────────────────────────────────────────────────

function JSXGraph.off(lb::JSXGraph.LiveBoard, elem::JSXGraph.AbstractJSXElement, event::Symbol)
    state = lb._state::_ServerState
    elem_id = _get_element_id(lb.board, elem)
    key = (elem_id, event)
    delete!(state.callbacks, key)

    _regenerate_html!(lb)

    return nothing
end

# ── update!() implementation ────────────────────────────────────────────────

function JSXGraph.update!(lb::JSXGraph.LiveBoard, elem::JSXGraph.AbstractJSXElement; kwargs...)
    lb.is_serving || error("LiveBoard is not serving. Call serve(board) first.")

    state = lb._state::_ServerState
    elem_id = _get_element_id(lb.board, elem)

    kw = Dict(kwargs)

    # Handle x, y → moveTo
    if haskey(kw, :x) || haskey(kw, :y)
        x = get(kw, :x, nothing)
        y = get(kw, :y, nothing)
        coords = [something(x, 0), something(y, 0)]
        _broadcast(state, Dict(
            "type" => "update",
            "element_id" => elem_id,
            "method" => "moveTo",
            "args" => [coords]
        ))
        delete!(kw, :x)
        delete!(kw, :y)
    end

    # Handle remaining kwargs → setAttribute
    if !isempty(kw)
        attrs = Dict{String,Any}(string(k) => v for (k, v) in kw)
        _broadcast(state, Dict(
            "type" => "update",
            "element_id" => elem_id,
            "method" => "setAttribute",
            "args" => [attrs]
        ))
    end

    return nothing
end

# ── Helper: regenerate HTML with current event registrations ────────────────

function _regenerate_html!(lb::JSXGraph.LiveBoard)
    state = lb._state::_ServerState

    registered_elements = Dict{String,Set{Symbol}}()
    for (elem_id, event) in keys(state.callbacks)
        if !haskey(registered_elements, elem_id)
            registered_elements[elem_id] = Set{Symbol}()
        end
        push!(registered_elements[elem_id], event)
    end

    state.board_html = _generate_served_html(lb.board, lb.port, registered_elements)
end

end # module JSXGraphHTTPExt
