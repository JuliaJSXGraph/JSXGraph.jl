#=
- button http://jsxgraph.org/docs/symbols/Button.html
- checkbox http://jsxgraph.org/docs/symbols/Checkbox.html
=#

mutable struct Slider <: Object
    name::String
    vals::Vector{Vector{<:Real}}
    opts::Option{LittleDict{Symbol,Any}}
end

"""
    slider(name, vals; opts...)

Create a new slider, add it to the current board.

* name - name of the slider ex: `"slider1"`
* vals - position and values of the slider ex: `[[0,0],[3,0],[0,1.5,3]]`
          first element is `[xa, ya]` (position of minimum value point)
          second element is `[xb, yb]` (position of maximum value point)
          third element is `[va, v0, vb]` (min value, default value, max value)
"""
function slider(name, vals; kw...)
    @assert length(vals) == 3 "`slider`::expected three subarrays in `vals`."
    @assert length(vals[1]) == 2 && length(vals[2]) == 2 && length(vals[3]) == 3 "`slider`::subvector dims should be 2,2,3."
    s = Slider(name, vals, dict(; kw...))
    return s
end
slider(name, a, b, v; kw...) = slider(name, [a, b, v]; kw...)

mutable struct Button{X<:FR,Y<:FR,F<:JSFun} <: Object
    name::String
    label::String
    x::X
    y::Y
    f::F
    opts::Option{LittleDict{Symbol,Any}}
end

"""
    button(name, label, x, y, f; opts...)
    button(label, x, y, f; opts)
"""
button(n, l, x, y, f; kw...) = Button(n, l, x, y, f, dict(; kw...))
button(l, x, y, f; kw...) = button("button_"*randstring(3), l, x, y, f; kw...)

# ---------------------------------------------------------------------------

val(s::Slider) = s.vals[3][2] # midvalue of last vector [va, v0, vb]

# ---------------------------------------------------------------------------

function str(s::Slider, b::Board)
    opts = get_opts(s)
    jss = js".create('slider', $(s.vals), $opts);"
    return "var $(s.name)=" * b.name * jss.s
end

function str(bu::Button, b::Board)
    xs, xss, xrp = strf(bu.x, "FX", b)
    ys, yss, yrp = strf(bu.y, "FY", b)
    fs, fss, frp = strf(bu.f, "FF", b)
    opts = get_opts(bu)
    jss = js".create('button', [$xss, $yss, $(bu.label), $fss], $opts);"
    return xs * ys * fs * b.name * replacefn(jss.s, xrp, yrp, frp)
end
