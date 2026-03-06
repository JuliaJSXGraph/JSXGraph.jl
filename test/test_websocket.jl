using Test
using JSXGraph
using HTTP
using HTTP.WebSockets
using JSON

function _wait_for_connections(lb, n::Int; timeout=5.0)
    state = lb._state
    t0 = time()
    while length(state.connections) < n && (time() - t0) < timeout
        sleep(0.05)
    end
    return length(state.connections) >= n
end

@testset "WebSocket Interactivity" begin

    @testset "Stub behavior without HTTP" begin
        # When HTTP IS loaded, the extension overrides stubs — tested implicitly
        # by all other tests in this file successfully calling serve/on/etc.
    end

    @testset "LiveBoard type" begin
        b = Board("ws_test", xlim=(-5,5), ylim=(-5,5))
        lb = LiveBoard(b, 0, false, nothing)
        @test lb.board === b
        @test lb.port == 0
        @test lb.is_serving == false
    end

    @testset "serve() and stop_server!() lifecycle" begin
        b = Board("lifecycle", xlim=(-5,5), ylim=(-5,5))
        p = point(0, 0; name="P")
        push!(b, p)

        lb = serve(b; port=0, open_browser=false)
        @test lb.port > 0
        @test lb.is_serving == true
        @test lb.board === b

        # Verify HTTP endpoint serves HTML
        resp = HTTP.get("http://127.0.0.1:$(lb.port)/")
        @test resp.status == 200
        html = String(resp.body)
        @test occursin("jsxgraphcore", html)
        @test occursin("WebSocket", html)
        @test occursin("ws://localhost:$(lb.port)/ws", html)

        # Verify 404 for unknown paths
        resp404 = HTTP.get("http://127.0.0.1:$(lb.port)/nonexistent"; status_exception=false)
        @test resp404.status == 404

        # Stop the server
        stop_server!(lb)
        @test lb.is_serving == false

        # Stopping again is a no-op
        stop_server!(lb)
        @test lb.is_serving == false
    end

    @testset "on() and off() callback registration" begin
        b = Board("callbacks", xlim=(-5,5), ylim=(-5,5))
        p = point(1, 2; name="P")
        s = slider([-4, 4], [0, 4], [0, 5, 10]; name="myslider")
        push!(b, p, s)

        lb = serve(b; port=0, open_browser=false)
        try
            # Register callbacks (use JSXGraph.on to avoid clash with Observables.on)
            received = Ref{Any}(nothing)
            JSXGraph.on(lb, p, :drag) do data
                received[] = data
            end

            # Verify supported events
            JSXGraph.on(lb, p, :click, d -> nothing)
            JSXGraph.on(lb, s, :change, d -> nothing)

            # Verify unsupported event throws
            @test_throws ArgumentError JSXGraph.on(lb, p, :unsupported, d -> nothing)

            # Verify off removes callback
            JSXGraph.off(lb, p, :drag)
            JSXGraph.off(lb, p, :click)
            JSXGraph.off(lb, s, :change)

            # Off on non-registered is fine (no-op)
            JSXGraph.off(lb, p, :drag)

            # Verify element not on board throws
            other_board = Board("other")
            other_point = point(0, 0)
            push!(other_board, other_point)
            @test_throws ArgumentError JSXGraph.on(lb, other_point, :drag, d -> nothing)
        finally
            stop_server!(lb)
        end
    end

    @testset "WebSocket event routing" begin
        b = Board("events", xlim=(-5,5), ylim=(-5,5))
        p = point(0, 0; name="P")
        push!(b, p)

        lb = serve(b; port=0, open_browser=false)
        try
            received = Channel{Dict{String,Any}}(10)

            JSXGraph.on(lb, p, :drag) do data
                put!(received, data)
            end

            # Connect a WebSocket client and send an event
            HTTP.WebSockets.open("ws://127.0.0.1:$(lb.port)/ws") do ws
                # Send a drag event
                event_msg = JSON.json(Dict(
                    "type" => "event",
                    "board_id" => "events",
                    "element_id" => "el_001",
                    "event" => "drag",
                    "data" => Dict("x" => 1.5, "y" => 2.3)
                ))
                send(ws, event_msg)

                # Wait for callback to fire
                data = timedwait(() -> isready(received), 2.0)
                @test data == :ok

                if data == :ok
                    result = take!(received)
                    @test result["x"] == 1.5
                    @test result["y"] == 2.3
                end
            end
        finally
            stop_server!(lb)
        end
    end

    @testset "update!() sends messages to browser" begin
        b = Board("updates", xlim=(-5,5), ylim=(-5,5))
        p = point(0, 0; name="P")
        push!(b, p)

        lb = serve(b; port=0, open_browser=false)
        ws_task = Ref{Task}()
        try
            received_msgs = Channel{Dict{String,Any}}(10)

            # Connect a WebSocket client to receive updates
            ws_task[] = @async begin
                HTTP.WebSockets.open("ws://127.0.0.1:$(lb.port)/ws") do ws
                    for msg_data in ws
                        msg = JSON.parse(String(msg_data))
                        if msg["type"] == "update"
                            put!(received_msgs, msg)
                        end
                    end
                end
            end

            # Wait for WebSocket client to connect
            @test _wait_for_connections(lb, 1)

            # Test moveTo
            update!(lb, p; x=3, y=4)
            result = timedwait(() -> isready(received_msgs), 3.0)
            @test result == :ok
            if result == :ok
                msg = take!(received_msgs)
                @test msg["element_id"] == "el_001"
                @test msg["method"] == "moveTo"
                @test msg["args"] == [[3, 4]]
            end

            # Test setAttribute
            update!(lb, p; strokeColor="red")
            result = timedwait(() -> isready(received_msgs), 3.0)
            @test result == :ok
            if result == :ok
                msg = take!(received_msgs)
                @test msg["element_id"] == "el_001"
                @test msg["method"] == "setAttribute"
                @test msg["args"] == [Dict("strokeColor" => "red")]
            end

            # Test combined x,y + attribute
            update!(lb, p; x=1, y=2, size=5)
            # Should produce two messages: moveTo and setAttribute
            collected = Dict{String,Any}[]
            for _ in 1:20
                if isready(received_msgs)
                    push!(collected, take!(received_msgs))
                end
                length(collected) >= 2 && break
                sleep(0.2)
            end
            @test length(collected) >= 2
            if length(collected) >= 2
                methods = Set([m["method"] for m in collected])
                @test "moveTo" in methods
                @test "setAttribute" in methods
            end
        finally
            # Stop the server first so WebSocket iteration ends
            stop_server!(lb)
            # Wait briefly for the async WS task to finish
            if isassigned(ws_task)
                timedwait(() -> istaskdone(ws_task[]), 3.0)
            end
        end
    end

    @testset "Callback error handling" begin
        b = Board("errors", xlim=(-5,5), ylim=(-5,5))
        p = point(0, 0; name="P")
        push!(b, p)

        lb = serve(b; port=0, open_browser=false)
        try
            # Register a callback that throws
            JSXGraph.on(lb, p, :drag) do data
                error("Test callback error")
            end

            # Send event via WebSocket — server should not crash
            HTTP.WebSockets.open("ws://127.0.0.1:$(lb.port)/ws") do ws
                event_msg = JSON.json(Dict(
                    "type" => "event",
                    "board_id" => "errors",
                    "element_id" => "el_001",
                    "event" => "drag",
                    "data" => Dict("x" => 1.0, "y" => 2.0)
                ))
                send(ws, event_msg)

                # Read response — should be an error notification
                response_data = receive(ws)
                response = JSON.parse(String(response_data))
                @test response["type"] == "error"
                @test occursin("Test callback error", response["message"])
            end

            # Server should still be running
            @test lb.is_serving == true

            # HTTP endpoint should still work
            resp = HTTP.get("http://127.0.0.1:$(lb.port)/")
            @test resp.status == 200
        finally
            stop_server!(lb)
        end
    end

    @testset "Multiple browser connections" begin
        b = Board("multi", xlim=(-5,5), ylim=(-5,5))
        p = point(0, 0; name="P")
        push!(b, p)

        lb = serve(b; port=0, open_browser=false)
        ws_task1 = Ref{Task}()
        ws_task2 = Ref{Task}()
        try
            received1 = Channel{Dict{String,Any}}(10)
            received2 = Channel{Dict{String,Any}}(10)

            # Connect two WebSocket clients
            ws_task1[] = @async HTTP.WebSockets.open("ws://127.0.0.1:$(lb.port)/ws") do ws
                for msg_data in ws
                    msg = JSON.parse(String(msg_data))
                    if msg["type"] == "update"
                        put!(received1, msg)
                    end
                end
            end

            ws_task2[] = @async HTTP.WebSockets.open("ws://127.0.0.1:$(lb.port)/ws") do ws
                for msg_data in ws
                    msg = JSON.parse(String(msg_data))
                    if msg["type"] == "update"
                        put!(received2, msg)
                    end
                end
            end

            # Wait for both WebSocket clients to connect
            @test _wait_for_connections(lb, 2)

            # Send update — both clients should receive it
            update!(lb, p; x=5, y=6)

            # Wait for both channels to receive messages
            got1 = false
            got2 = false
            for _ in 1:30
                got1 = got1 || isready(received1)
                got2 = got2 || isready(received2)
                (got1 && got2) && break
                sleep(0.2)
            end
            @test got1
            @test got2

            if got1
                msg1 = take!(received1)
                @test msg1["args"] == [[5, 6]]
            end
            if got2
                msg2 = take!(received2)
                @test msg2["args"] == [[5, 6]]
            end
        finally
            # Stop the server first so WebSocket iteration ends
            stop_server!(lb)
            # Wait briefly for async WS tasks to finish
            if isassigned(ws_task1) && isassigned(ws_task2)
                timedwait(() -> istaskdone(ws_task1[]) && istaskdone(ws_task2[]), 3.0)
            end
        end
    end

    @testset "update!() requires serving" begin
        b = Board("notserving", xlim=(-5,5), ylim=(-5,5))
        p = point(0, 0)
        push!(b, p)

        lb = serve(b; port=0, open_browser=false)
        stop_server!(lb)

        @test_throws ErrorException update!(lb, p; x=1, y=2)
    end

    @testset "HTML contains event listeners after on()" begin
        b = Board("listeners", xlim=(-5,5), ylim=(-5,5))
        p = point(0, 0; name="P")
        push!(b, p)

        lb = serve(b; port=0, open_browser=false)
        try
            # Before registering callbacks — no event listeners in HTML
            resp1 = HTTP.get("http://127.0.0.1:$(lb.port)/")
            html1 = String(resp1.body)
            @test !occursin("el_001.on(", html1)

            # Register a drag callback
            JSXGraph.on(lb, p, :drag, d -> nothing)

            # After registering — HTML should have event listener
            resp2 = HTTP.get("http://127.0.0.1:$(lb.port)/")
            html2 = String(resp2.body)
            @test occursin("el_001.on(", html2)

            # Remove callback
            JSXGraph.off(lb, p, :drag)

            # After removing — no event listener
            resp3 = HTTP.get("http://127.0.0.1:$(lb.port)/")
            html3 = String(resp3.body)
            @test !occursin("el_001.on(", html3)
        finally
            stop_server!(lb)
        end
    end

end
