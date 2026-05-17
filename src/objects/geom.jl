mutable struct Point{X<:FR,Y<:FR} <: Object
    x::X
    y::Y
    opts::Option{LittleDict{Symbol,Any}}
end

point(x::FR, y::FR; kw...) = Point(x, y, dict(; kw...))
point(x::FR, y::FR, d::LittleDict{Symbol,Any}) = Point(x, y, d)
point(n::String, x, y; kw...) = point(x, y; name=n, kw...)

# ---------------------------------------------------------------------------

function str(p::Point, b::Board)
    xs, xss, xrp = strf(p.x, "FX", b)
    ys, yss, yrp = strf(p.y, "FY", b)
    opts = get_opts(p)
    jss = js".create('point', [$xss, $yss], $opts);"
    name = get(opts, :name, nothing)
    isnothing(name) && return xs * ys * b.name * replacefn(jss.s, xrp, yrp)
    return xs * ys * "var $name =" * b.name * replacefn(jss.s, xrp, yrp)
end
