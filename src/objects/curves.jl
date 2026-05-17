#=
- curve http://jsxgraph.org/docs/symbols/Curve.html
- datacurve ? (via curve)
=#

mutable struct FunctionGraph <: Object
    f::JSFun
    a::Union{Nothing,<:Real}
    b::Union{Nothing,<:Real}
    # --- other board options --- jsxgraph.org/docs/symbols/Functiongraph.html
    opts::Option{LittleDict{Symbol,Any}}
end

"""
    functiongraph(f; a, b)

* `f` - a function of a single parameter `x` ex: (x -> 3x)
* `a` - optionally set the minimum value of `x`
* `b` - optionall set the maximum value of `x`
"""
function functiongraph(f::JSFun; a=nothing, b=nothing, kw...)
    return FunctionGraph(f, a, b, dict(; kw...))
end

# ---------------------------------------------------------------------------

function str(fg::FunctionGraph, b::Board)
    xmin = ifelse(isnothing(fg.a), b.xlim[1], fg.a)
    xmax = ifelse(isnothing(fg.b), b.xlim[2], fg.b)
    opts = get_opts(fg)
    fs, fss, frp = strf(fg.f, "FN", b)
    jss = js".create('functiongraph', [$fss, $xmin, $xmax], $opts);"
    return fs * b.name * replacefn(jss.s, frp)
end

# ===========================================================================

abstract type Curve{X,Y,A,B} <: Object end

mutable struct ParametricCurve{X<:FR,Y<:FR,A<:FR,B<:FR} <: Curve{X,Y,A,B}
    x::X
    y::Y
    a::A
    b::B
    # -- opts -- jsxgraph.org/docs/symbols/Curve.html
    opts::Option{LittleDict{Symbol,Any}}
end
function parametriccurve(f::FR, g::FR; a::Option{FR}=nothing, b::Option{FR}=nothing, kw...)
    return ParametricCurve(f, g, a, b, dict(; kw...))
end

mutable struct DataPlot{X<:AR,Y<:AFR} <: Curve{X,Y,Nothing,Nothing}
    x::X
    y::Y
    # -- opts -- jsxgraph.org/docs/symbols/Curve.html
    opts::Option{LittleDict{Symbol,Any}}
end
dataplot(x::AR, y::JSFun; kw...) = DataPlot(x, y, dict(; kw...))
dataplot(x::AR, y::AR; kw...) = (check_dims(x, y); DataPlot(x, y, dict(; kw...)))

mutable struct PolarCurve{R<:JSFun,O<:AFR,A<:FR,B<:FR} <: Curve{R,O,A,B}
    r::R
    o::O
    a::A
    b::B
    # -- opts -- jsxgraph.org/docs/symbols/Curve.html
    opts::Option{LittleDict{Symbol,Any}}
end
function polarcurve(
    r::JSFun, o::AFR=[0, 0]; a::Option{FR}=nothing, b::Option{FR}=nothing, kw...
)
    return PolarCurve(r, o, a, b, dict(; kw...))
end

# ---------------------------------------------------------------------------

function str(pc::ParametricCurve, b::Board)
    isnothing(pc.a) && (pc.a = -10)
    isnothing(pc.b) && (pc.b = xmax)
    xs, xss, xrp = strf(pc.x, "FX", b)
    ys, yss, yrp = strf(pc.y, "FY", b)
    as, ass, arp = strf(pc.a, "FA", b)
    bs, bss, brp = strf(pc.b, "FB", b)
    opts = get_opts(pc)
    jss = js".create('curve', [$xss, $yss, $ass, $bss], $opts);"
    return xs * ys * as * bs * b.name * replacefn(jss.s, xrp, yrp, arp, brp)
end

function str(pc::PolarCurve, b::Board)
    isnothing(pc.a) && (pc.a = -10)
    isnothing(pc.b) && (pc.b = 10)
    opts = get_opts(pc)
    rs, rss, rrp = strf(pc.r, "FR", b)
    os, oss, orp = strf(pc.o, "FO", b)
    as, ass, arp = strf(pc.a, "FA", b)
    bs, bss, brp = strf(pc.b, "FB", b)
    jss = js".create('curve', [$rss, $oss, $ass, $bss], $opts)"
    return rs * os * as * bs * b.name * replacefn(jss.s, rrp, orp, arp, brp)
end

function str(dp::DataPlot, b::Board)
    opts = get_opts(dp)
    jss = js".create('curve', [$(dp.x), $(dp.y)], $opts);"
    return b.name * jss.s
end

# ===========================================================================

plot(f::FR, g::FR; kw...) = parametriccurve(f, g; kw...)
plot(x::AR, y::AFR; kw...) = dataplot(x, y; kw...)

function plot(f::JSFun; kw...)
    if :curvetype in keys(kw) && kw[:curvetype] == "polar"
        return polarcurve(f; kw...)
    end
    return functiongraph(f; kw...)
end
