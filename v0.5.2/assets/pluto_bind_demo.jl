### A Pluto.jl notebook ###
# v0.20.25

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 22222222-2222-2222-2222-222222222222
begin
    using Pkg
    # Pluto auto-adds `JSXGraph` from the General registry, which (until
    # 0.6 is published) currently resolves to a different UUID than the
    # local checkout. Remove that auto-added entry (if present), then
    # develop the local path. Adjust `path=...` if you place this
    # notebook elsewhere.
    try
        Pkg.rm("JSXGraph")
    catch
    end
    Pkg.develop(PackageSpec(path = joinpath(@__DIR__, "..", "..")))
    using JSXGraph
end

# ╔═╡ 11111111-1111-1111-1111-111111111111
md"""
# JSXGraph.jl + Pluto `@bind`

This notebook demonstrates JSXGraph.jl's Pluto integration. Drag the
points in the board below — the cells below it re-execute reactively
with the new coordinates.

The key ingredient is `bindable=true` on `board(...)`, plus the standard
`@bind` macro to surface the board's interactive state as a Julia
variable.
"""

# ╔═╡ 77777777-7777-7777-7777-777777777777
@bind state board("demo"; xlim=(-5, 5), ylim=(-5, 5), bindable=true) do b
    push!(b, point(-2.0,  1.0; name="A"))
    push!(b, point( 0.0, -1.0; name="B"))
    push!(b, point( 2.0,  2.0; name="C"))
end

# ╔═╡ 33333333-3333-3333-3333-333333333333
md"## Raw bound state"

# ╔═╡ aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
state

# ╔═╡ 44444444-4444-4444-4444-444444444444
md"## Parallel coordinate vectors

`points_xy(state)` projects the bound state into two `Vector{Float64}`s,
in element-declaration order."

# ╔═╡ 88888888-8888-8888-8888-888888888888
xs, ys = points_xy(state)

# ╔═╡ 55555555-5555-5555-5555-555555555555
md"## Live derivation

Any downstream cell that reads `state`, `xs`, or `ys` re-evaluates
each time you drag a point."

# ╔═╡ 99999999-9999-9999-9999-999999999999
let
    n = length(xs)
    sumx = isempty(xs) ? 0.0 : sum(xs)
    centroid_x = isempty(xs) ? 0.0 : sumx / n
    centroid_y = isempty(ys) ? 0.0 : sum(ys) / n
    "centroid of the $(n) draggable points is ($(round(centroid_x; digits=3)), $(round(centroid_y; digits=3)))"
end

# ╔═╡ Cell order:
# ╠═22222222-2222-2222-2222-222222222222
# ╟─11111111-1111-1111-1111-111111111111
# ╠═77777777-7777-7777-7777-777777777777
# ╟─33333333-3333-3333-3333-333333333333
# ╠═aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
# ╟─44444444-4444-4444-4444-444444444444
# ╠═88888888-8888-8888-8888-888888888888
# ╟─55555555-5555-5555-5555-555555555555
# ╠═99999999-9999-9999-9999-999999999999
