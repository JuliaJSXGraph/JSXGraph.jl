mutable struct ScatterPlot <: Object
    points::Vector{Point}
end

function scatterplot(x::AR, y::AR; kw...)
    check_dims(x, y)
    opts = dict(; kw...)
    points = [point(xi, yi, opts) for (xi, yi) in zip(x, y)]
    return ScatterPlot(points)
end

function scatterplot(x::AR, y::JSFun; kw...)
    opts = dict(; kw...)
    points = [point(xi, y, opts) for xi in x]
    return ScatterPlot(points)
end

function str(pc::ScatterPlot, b::Board)
    return prod(str(p, b) for p in pc.points)
end

scatter = scatterplot
