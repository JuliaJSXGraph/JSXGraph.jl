# Minimal WebSocket example: live random walk
#
# Run with:
#   julia examples/websocket/minimal.jl
#
# A browser window will open showing a point that follows a 2D random walk,
# updated in real time via WebSocket.

using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using JSXGraph
using HTTP  # triggers the WebSocket extension

# Build the board with a draggable point at the origin
b = Board("random_walk", xlim=(-10, 10), ylim=(-10, 10))
p = point(0, 0; name="Walker", size=4, strokeColor="blue", fillColor="blue")
push!(b, p)

# Start the server (opens in browser automatically)
lb = serve(b)

println("Random walk running on http://127.0.0.1:$(lb.port)")
println("Press Ctrl+C to stop.")

# Animate a 2D random walk
x, y = 0.0, 0.0
step = 0.3
try
    while true
        global x += step * randn()
        global y += step * randn()
        x = clamp(x, -10, 10)
        y = clamp(y, -10, 10)
        update!(lb, p; x=x, y=y)
        sleep(0.1)
    end
catch e
    e isa InterruptException || rethrow()
finally
    stop_server!(lb)
    println("Server stopped.")
end
