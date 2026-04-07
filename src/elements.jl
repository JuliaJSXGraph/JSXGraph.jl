# Element types and constructors

"""
$(TYPEDEF)

Represents a JavaScript function string for use in JSXGraph element parents.

A `JSFunction` can optionally be *named* so that other `JSFunction` objects
can reference it, and it can carry a list of *dependencies* on other named
`JSFunction` objects.  The rendering pipeline automatically collects all
transitive dependencies and emits named function definitions before the
elements that use them.

$(TYPEDFIELDS)
"""
struct JSFunction
    "JavaScript function code string"
    code::String
    "Optional name for this function (empty string = anonymous)"
    name::String
    "Other named JSFunction objects this function depends on"
    deps::Vector{JSFunction}
end

# Backward-compatible constructors
JSFunction(code::String) = JSFunction(code, "", JSFunction[])
JSFunction(code::String, name::String) = JSFunction(code, name, JSFunction[])

"""
$(TYPEDEF)

Represents a single JSXGraph element that can be placed on a board.

Each element has a type name (e.g., "point", "line"), parent arguments,
and visual/behavioral attributes that are passed to `board.create()`.

$(TYPEDFIELDS)
"""
struct JSXElement <: AbstractJSXElement
    "JSXGraph element type (e.g., \"point\", \"line\", \"circle\")"
    type_name::String
    "Positional arguments for board.create()"
    parents::Vector{Any}
    "Visual and behavioral attributes"
    attributes::Dict{String,Any}
end

"""
$(SIGNATURES)

Create a JSXGraph element with the given type name, parents, and keyword attributes.
"""
function _create_element(type_name::String, parents, kwargs)
    attrs = resolve_aliases(kwargs)
    attrs = convert_color_values(attrs)
    attrs = apply_theme_defaults(type_name, attrs)
    return JSXElement(type_name, collect(Any, parents), attrs)
end

"""
$(SIGNATURES)

Convert a parent value to its JavaScript string representation.

Handles Numbers, Strings, Vectors/Tuples, JSXElement references, and JSFunction objects.
"""
function parent_to_js(x::Number, elem_ids::Dict)
    return string(x)
end

function parent_to_js(x::String, elem_ids::Dict)
    return JSON.json(x)
end

function parent_to_js(x::AbstractVector, elem_ids::Dict)
    items = [parent_to_js(item, elem_ids) for item in x]
    return "[" * join(items, ",") * "]"
end

function parent_to_js(x::Tuple, elem_ids::Dict)
    items = [parent_to_js(item, elem_ids) for item in x]
    return "[" * join(items, ",") * "]"
end

function parent_to_js(x::JSXElement, elem_ids::Dict)
    id = objectid(x)
    if haskey(elem_ids, id)
        return elem_ids[id]
    end
    error(
        "Element reference not found. Ensure the referenced element is added to the board before elements that depend on it.",
    )
end

function parent_to_js(x::JSFunction, elem_ids::Dict)
    return x.code
end

# Fallback: unwrap via resolve_value and re-dispatch (enables Observable support)
function parent_to_js(x, elem_ids::Dict)
    resolved = resolve_value(x)
    resolved === x && error("No parent_to_js method for $(typeof(x))")
    return parent_to_js(resolved, elem_ids)
end

"""
$(SIGNATURES)

Convert element attributes to a JSON string.
"""
function attrs_to_js(attrs::Dict{String,Any})
    return sorted_json(attrs)
end

# --- Geometric Primitives ---

"""
$(SIGNATURES)

Create a point at coordinates `(x, y)`.
"""
point(x, y; kwargs...) = _create_element("point", (x, y), kwargs)

"""
$(SIGNATURES)

Create a line through two points or defined by other parents.
"""
line(a, b; kwargs...) = _create_element("line", (a, b), kwargs)

"""
$(SIGNATURES)

Create a line segment between two points.
"""
segment(a, b; kwargs...) = _create_element("segment", (a, b), kwargs)

"""
$(SIGNATURES)

Create an arrow from point `a` to point `b`.
"""
arrow(a, b; kwargs...) = _create_element("arrow", (a, b), kwargs)

"""
$(SIGNATURES)

Create a circle with center and radius or point on circle.
"""
function circle(center, radius_or_point; kwargs...)
    _create_element("circle", (center, radius_or_point), kwargs)
end

"""
$(SIGNATURES)

Create an arc from center through two boundary points.
"""
arc(center, p1, p2; kwargs...) = _create_element("arc", (center, p1, p2), kwargs)

"""
$(SIGNATURES)

Create a sector from center through two boundary points.
"""
sector(center, p1, p2; kwargs...) = _create_element("sector", (center, p1, p2), kwargs)

"""
$(SIGNATURES)

Create a polygon through the given vertices.
"""
polygon(points...; kwargs...) = _create_element("polygon", points, kwargs)

"""
$(SIGNATURES)

Create a regular polygon with `n` sides from two points.
"""
function regularpolygon(p1, p2, n; kwargs...)
    _create_element("regularpolygon", (p1, p2, n), kwargs)
end

"""
$(SIGNATURES)

Create an angle defined by three points.
"""
angle(p1, vertex, p2; kwargs...) = _create_element("angle", (p1, vertex, p2), kwargs)

"""
$(SIGNATURES)

Create a conic section through five points.
"""
function conic(p1, p2, p3, p4, p5; kwargs...)
    _create_element("conic", (p1, p2, p3, p4, p5), kwargs)
end

"""
$(SIGNATURES)

Create an ellipse with two foci and a point on the ellipse.
"""
ellipse(f1, f2, p; kwargs...) = _create_element("ellipse", (f1, f2, p), kwargs)

"""
$(SIGNATURES)

Create a parabola with focus and directrix.
"""
function parabola(focus, directrix; kwargs...)
    _create_element("parabola", (focus, directrix), kwargs)
end

"""
$(SIGNATURES)

Create a hyperbola with two foci and a point on the hyperbola.
"""
hyperbola(f1, f2, p; kwargs...) = _create_element("hyperbola", (f1, f2, p), kwargs)

# --- Analytic Elements ---

"""
Helper to convert a function, expression, or string to a JSFunction.

The optional `arity` parameter controls the number of parameters in the
generated JavaScript function wrapper (only used for String inputs).

For `String` inputs:
- Strings already starting with `function` are used as-is.
- Other strings are wrapped as `function(x){return <expr>;}` (arity=1)
  or `function(x,y){return <expr>;}` (arity=2), etc.
- The `param_names` keyword overrides the default parameter names.

For `Function` and `Expr` inputs, `arity` and `param_names` are ignored
(the lambda structure determines the parameter list).
"""
function _to_jsfunction(f::Function, arity::Int=1; param_names=nothing)
    return JSFunction(julia_to_js(f))
end

function _to_jsfunction(expr::Expr, arity::Int=1; param_names=nothing)
    return JSFunction(julia_to_js(expr))
end

const _JS_PARAM_NAMES = ["x", "y", "z", "w"]

function _to_jsfunction(x::AbstractString, arity::Int=1; param_names=nothing)
    stripped = strip(x)
    # If the string is already a complete function expression, use as-is
    if startswith(stripped, "function")
        return JSFunction(String(stripped))
    end
    names = param_names !== nothing ? param_names : _JS_PARAM_NAMES
    params = join(names[1:arity], ",")
    return JSFunction("function($params){return $x;}")
end

function _to_jsfunction(x::JSXElement, arity::Int=1; param_names=nothing)
    # For curve-like elements (functiongraph, curve), extract underlying JSFunction.
    # This lets users write e.g. `riemannsum(functiongraph_elem, ...)`
    # and have the function passed correctly to JSXGraph.
    if !isempty(x.parents) && x.parents[1] isa JSFunction
        return x.parents[1]
    end
    return x
end

function _to_jsfunction(x, arity::Int=1; param_names=nothing)
    return x
end

"""
$(SIGNATURES)

Create a function graph element from a Julia function or expression.
"""
function functiongraph(f; kwargs...)
    jsf = _to_jsfunction(f)
    return _create_element("functiongraph", (jsf,), kwargs)
end

"""
$(SIGNATURES)

Create a parametric curve from `fx(t)`, `fy(t)` over `[t_start, t_end]`.
"""
function curve(fx, fy, t_start, t_end; kwargs...)
    jsfx = _to_jsfunction(fx)
    jsfy = _to_jsfunction(fy)
    return _create_element("curve", (jsfx, jsfy, t_start, t_end), kwargs)
end

"""
$(SIGNATURES)

Create an implicit curve from a function `f(x, y) = 0`.
"""
function implicitcurve(f; kwargs...)
    jsf = _to_jsfunction(f, 2)
    return _create_element("implicitcurve", (jsf,), kwargs)
end

"""
$(SIGNATURES)

Create an inequality region from a line element.
"""
inequality(line_elem; kwargs...) = _create_element("inequality", (line_elem,), kwargs)

"""
$(SIGNATURES)

Create a tangent line at a glider point.
"""
tangent(glider_elem; kwargs...) = _create_element("tangent", (glider_elem,), kwargs)

"""
$(SIGNATURES)

Create a normal line at a glider point.
"""
normal(glider_elem; kwargs...) = _create_element("normal", (glider_elem,), kwargs)

"""
$(SIGNATURES)

Create an integral of a curve between bounds `a` and `b`.
"""
function integral(curve_elem, a, b; kwargs...)
    _create_element("integral", (curve_elem, a, b), kwargs)
end

"""
$(SIGNATURES)

Create the derivative of a curve element.
"""
derivative(curve_elem; kwargs...) = _create_element("derivative", (curve_elem,), kwargs)

"""
$(SIGNATURES)

Create a Riemann sum visualization.
"""
function riemannsum(f, n, type; a=-5, b=5, kwargs...)
    jsf = _to_jsfunction(f)
    return _create_element("riemannsum", (jsf, n, type, a, b), kwargs)
end

"""
$(SIGNATURES)

Create a slope field visualization.

# Arguments
- `f`: Function `f(x, y)` returning a slope value (Function, Expr, or String)
- `xData`: Grid range for x as `[xmin, step, xmax]` (default: `[-5, 1, 5]`)
- `yData`: Grid range for y as `[ymin, step, ymax]` (default: `[-5, 1, 5]`)

# Example
```julia
slopefield("x - y")  # uses default grid
slopefield("x - y", [-10, 0.5, 10], [-10, 0.5, 10])  # custom grid
```
"""
function slopefield(f, xData=[-5, 1, 5], yData=[-5, 1, 5]; kwargs...)
    jsf = _to_jsfunction(f, 2)
    return _create_element("slopefield", (jsf, xData, yData), kwargs)
end

"""
$(SIGNATURES)

Create a vector field visualization.

# Arguments
- `f`: Function `f(x, y)` returning `[vx, vy]` (Function, Expr, or String)
- `xData`: Grid range for x as `[xmin, step, xmax]` (default: `[-5, 1, 5]`)
- `yData`: Grid range for y as `[ymin, step, ymax]` (default: `[-5, 1, 5]`)

# Example
```julia
vectorfield(@jsf((x, y) -> [y, -x]))  # uses default grid
vectorfield(@jsf((x, y) -> [y, -x]), [-10, 0.5, 10], [-10, 0.5, 10])  # custom grid
```
"""
function vectorfield(f, xData=[-5, 1, 5], yData=[-5, 1, 5]; kwargs...)
    jsf = _to_jsfunction(f, 2)
    return _create_element("vectorfield", (jsf, xData, yData), kwargs)
end

# --- Interactive Elements ---

"""
$(SIGNATURES)

Create a slider between positions `pos1` and `pos2` with `range` `[min, start, max]`.
"""
function slider(pos1, pos2, range; kwargs...)
    _create_element("slider", (pos1, pos2, range), kwargs)
end

"""
$(SIGNATURES)

Create a checkbox at position `(x, y)` with the given label.
"""
checkbox(x, y, label; kwargs...) = _create_element("checkbox", (x, y, label), kwargs)

"""
$(SIGNATURES)

Create a text input at position `(x, y)` with initial value and label.
"""
function input(x, y, value, label; kwargs...)
    _create_element("input", (x, y, value, label), kwargs)
end

"""
$(SIGNATURES)

Create a button at position `(x, y)` with label and handler.
"""
function button(x, y, label, handler; kwargs...)
    _create_element("button", (x, y, label, handler), kwargs)
end

"""
$(SIGNATURES)

Create a glider point on a curve element at initial position `(x, y)`.
"""
glider(x, y, curve_elem; kwargs...) = _create_element("glider", (x, y, curve_elem), kwargs)

"""
$(SIGNATURES)

Create a tape measure between two points.
"""
tapemeasure(p1, p2; kwargs...) = _create_element("tapemeasure", (p1, p2), kwargs)

"""
$(SIGNATURES)

Create a text element at position `(x, y)` with the given content.
"""
text(x, y, content; kwargs...) = _create_element("text", (x, y, content), kwargs)

"""
$(SIGNATURES)

Create an image element from a URL at the given corner with dimensions.
"""
image(url, corner, dims; kwargs...) = _create_element("image", (url, corner, dims), kwargs)

# --- Composition & Transformation Elements ---

"""
$(SIGNATURES)

Create a group element that groups several elements together for collective transformations.

`elements` should be a collection of `JSXElement` objects to group.

# Example
```julia
p1 = point(0, 0)
p2 = point(1, 1)
l = line(p1, p2)
g = group(p1, p2, l)
```
"""
group(elements...; kwargs...) = _create_element("group", elements, kwargs)

"""
$(SIGNATURES)

Create a generic transformation element.

`type` is one of `"translate"`, `"scale"`, `"rotate"`, `"reflect"`, `"shear"`, `"generic"`.
`params` are the transformation parameters (interpretation depends on `type`).

# Example
```julia
# Translation by (2, 3)
t = transformation("translate", 2, 3)

# Rotation by π/4 around the origin
t = transformation("rotate", π/4)

# Rotation by π/4 around point (1, 1)
t = transformation("rotate", π/4, 1, 1)
```
"""
function transformation(type::String, params...; kwargs...)
    _create_element("transformation", (collect(Any, params), type), kwargs)
end

"""
$(SIGNATURES)

Create a reflection transformation across the given line element.

# Example
```julia
p1 = point(0, 0)
p2 = point(1, 0)
l = line(p1, p2)
r = reflection(l)
```
"""
reflection(line_elem; kwargs...) = _create_element("reflection", (line_elem,), kwargs)

"""
$(SIGNATURES)

Create a rotation transformation by `angle` (in radians) around a `center` point.

# Example
```julia
c = point(0, 0)
r = rotation(c, π/4)
```
"""
rotation(center, angle; kwargs...) = _create_element("rotation", (center, angle), kwargs)

"""
$(SIGNATURES)

Create a translation transformation by vector `(dx, dy)`.

# Example
```julia
t = translation(2, 3)
```
"""
translation(dx, dy; kwargs...) = _create_element("translation", (dx, dy), kwargs)

"""
$(SIGNATURES)

Create a grid element on the board.

The grid is a visual overlay of horizontal and vertical lines.

# Example
```julia
g = grid()
g = grid(; face="line", majorStep=[1, 1])
```
"""
grid(; kwargs...) = _create_element("grid", (), kwargs)

"""
$(SIGNATURES)

Create an axis element defined by two points.

# Example
```julia
# Horizontal axis
ax = axis(point(0, 0), point(1, 0); name="x")

# Vertical axis
ay = axis(point(0, 0), point(0, 1); name="y")
```
"""
axis(p1, p2; kwargs...) = _create_element("axis", (p1, p2), kwargs)

"""
$(SIGNATURES)

Create a ticks element on a line or axis.

`line_or_axis` is the parent line/axis element. `tick_distance` is the distance between
major ticks (optional).

# Example
```julia
ax = axis(point(0, 0), point(1, 0))
t = ticks(ax, 1.0)
t = ticks(ax, 1.0; minorTicks=4, drawLabels=true)
```
"""
ticks(line_or_axis, tick_distance; kwargs...) = _create_element("ticks", (line_or_axis, tick_distance), kwargs)

"""
$(SIGNATURES)

Create a ticks element with default tick distance on a line or axis.

# Example
```julia
ax = axis(point(0, 0), point(1, 0))
t = ticks(ax)
```
"""
ticks(line_or_axis; kwargs...) = _create_element("ticks", (line_or_axis,), kwargs)

"""
$(SIGNATURES)

Create a legend element for the board.

`labels` is a vector of strings, and `elements` is a corresponding vector of elements
whose appearance styles will label the legend entries.

# Example
```julia
fg1 = functiongraph(sin; color="blue")
fg2 = functiongraph(cos; color="red")
leg = legend(fg1, fg2; labels=["sin", "cos"])
```
"""
legend(elements...; kwargs...) = _create_element("legend", elements, kwargs)

# --- 3D Elements ---

"""
$(SIGNATURES)

Create a 3D viewport container with explicit positional arguments.

# Arguments
- `position`: `[x, y]` bottom-left corner of the viewport on the 2D board
- `size`: `[width, height]` of the viewport
- `ranges`: `[[xMin, xMax], [yMin, yMax], [zMin, zMax]]` 3D axis ranges

# Example
```julia
v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-5, 5]])
```
"""
function view3d(position, size, ranges; kwargs...)
    attrs = resolve_aliases(kwargs)
    attrs = convert_color_values(attrs)
    attrs = apply_theme_defaults("view3d", attrs)
    return View3D("view3d", Any[position, size, ranges], attrs, AbstractJSXElement[])
end

"""
$(SIGNATURES)

Create a 3D viewport with keyword arguments for axis ranges.

# Arguments
- `position`: `[x, y]` bottom-left corner (default: `[-6, -3]`)
- `size`: `[width, height]` of the viewport (default: `[8, 8]`)
- `xlim`: x-axis range (default: `(-5, 5)`)
- `ylim`: y-axis range (default: `(-5, 5)`)
- `zlim`: z-axis range (default: `(-5, 5)`)

# Example
```julia
v = view3d(xlim=(-3, 3), ylim=(-3, 3), zlim=(-3, 3))
```
"""
function view3d(;
    position=[-6, -3],
    size=[8, 8],
    xlim::Tuple{Real,Real}=(-5, 5),
    ylim::Tuple{Real,Real}=(-5, 5),
    zlim::Tuple{Real,Real}=(-5, 5),
    kwargs...,
)
    ranges = [[xlim[1], xlim[2]], [ylim[1], ylim[2]], [zlim[1], zlim[2]]]
    return view3d(position, size, ranges; kwargs...)
end

"""
$(SIGNATURES)

Create a 3D point at coordinates `(x, y, z)`.

# Example
```julia
p = point3d(1, 2, 3; size=5, color="red")
```
"""
point3d(x, y, z; kwargs...) = _create_element("point3d", (x, y, z), kwargs)

"""
$(SIGNATURES)

Create a 3D line through two points.

# Example
```julia
p1 = point3d(0, 0, 0)
p2 = point3d(1, 1, 1)
l = line3d(p1, p2)
```
"""
line3d(p1, p2; kwargs...) = _create_element("line3d", (p1, p2), kwargs)

"""
$(SIGNATURES)

Create a 3D parametric curve from `fx(t)`, `fy(t)`, `fz(t)` over `t_range`.

# Arguments
- `fx`, `fy`, `fz`: functions or expressions for each coordinate
- `t_range`: parameter range as `[t_start, t_end]`

# Example
```julia
# Helix
c = curve3d(
    "Math.cos(t)", "Math.sin(t)", "t/(2*Math.PI)",
    [-6.28, 6.28]
)
```
"""
function curve3d(fx, fy, fz, t_range; kwargs...)
    jsfx = _to_jsfunction(fx; param_names=["t"])
    jsfy = _to_jsfunction(fy; param_names=["t"])
    jsfz = _to_jsfunction(fz; param_names=["t"])
    return _create_element("curve3d", (jsfx, jsfy, jsfz, t_range), kwargs)
end

"""
$(SIGNATURES)

Create a 3D function graph surface `z = f(x, y)`.

# Arguments
- `f`: function of two variables (Function, Expr, or String)
- `xlim`: optional x range as `(xmin, xmax)` (defaults to view range)
- `ylim`: optional y range as `(ymin, ymax)` (defaults to view range)

# Example
```julia
fg = functiongraph3d("Math.sin(x)*Math.cos(y)")
fg = functiongraph3d("x*y"; xlim=(-3, 3), ylim=(-3, 3))
```
"""
function functiongraph3d(f; xlim=nothing, ylim=nothing, kwargs...)
    jsf = _to_jsfunction(f, 2)
    parents = Any[jsf]
    if xlim !== nothing
        push!(parents, [xlim[1], xlim[2]])
    end
    if ylim !== nothing
        push!(parents, [ylim[1], ylim[2]])
    end
    return _create_element("functiongraph3d", Tuple(parents), kwargs)
end

"""
$(SIGNATURES)

Create a 3D parametric surface from `fx(u,v)`, `fy(u,v)`, `fz(u,v)`.

# Arguments
- `fx`, `fy`, `fz`: functions of two parameters (Function, Expr, or String)
- `u_range`: parameter u range as `[umin, umax]`
- `v_range`: parameter v range as `[vmin, vmax]`

# Example
```julia
# Sphere
ps = parametricsurface3d(
    "Math.sin(u)*Math.cos(v)",
    "Math.sin(u)*Math.sin(v)",
    "Math.cos(u)",
    [0, 3.14], [0, 6.28]
)
```
"""
function parametricsurface3d(fx, fy, fz, u_range, v_range; kwargs...)
    jsfx = _to_jsfunction(fx, 2; param_names=["u", "v"])
    jsfy = _to_jsfunction(fy, 2; param_names=["u", "v"])
    jsfz = _to_jsfunction(fz, 2; param_names=["u", "v"])
    return _create_element("parametricsurface3d", (jsfx, jsfy, jsfz, u_range, v_range), kwargs)
end

"""
$(SIGNATURES)

Create a 3D vector field from three component functions `fx(x,y,z)`, `fy(x,y,z)`, `fz(x,y,z)`.

# Arguments
- `fx`, `fy`, `fz`: component functions (Function, Expr, or String) of three variables
- `xrange`: x sampling range as `[start, steps, end]`
- `yrange`: y sampling range as `[start, steps, end]`
- `zrange`: z sampling range as `[start, steps, end]`

Each range specifies `[startValue, numberOfSteps, endValue]`, producing `steps + 1` vectors
along that axis.

# Example
```julia
vf = vectorfield3d(
    "Math.cos(y)", "Math.sin(x)", "z",
    [-2, 5, 2], [-2, 5, 2], [-2, 5, 2];
    strokeColor="red", scale=0.5,
)
```
"""
function vectorfield3d(fx, fy, fz, xrange, yrange, zrange; kwargs...)
    jsfx = _to_jsfunction(fx, 3; param_names=["x", "y", "z"])
    jsfy = _to_jsfunction(fy, 3; param_names=["x", "y", "z"])
    jsfz = _to_jsfunction(fz, 3; param_names=["x", "y", "z"])
    funcs = [jsfx, jsfy, jsfz]
    return _create_element("vectorfield3d", (funcs, xrange, yrange, zrange), kwargs)
end

"""
$(SIGNATURES)

Create a 3D sphere from a center point and radius (or a second point on the surface).

# Arguments
- `center`: center point (Point3D element)
- `radius_or_point`: radius (Number) or a Point3D on the surface

# Example
```julia
c = point3d(0, 0, 0)
s = sphere3d(c, 2.0; fillColor="blue", fillOpacity=0.3)
```
"""
sphere3d(center, radius_or_point; kwargs...) =
    _create_element("sphere3d", (center, radius_or_point), kwargs)

"""
$(SIGNATURES)

Create a 3D circle from a center point, normal vector, and radius.

# Arguments
- `center`: center point (Point3D element)
- `normal`: normal vector as `[0, nx, ny, nz]` (homogeneous coordinates)
- `radius`: circle radius (Number)

# Example
```julia
c = point3d(0, 0, 0)
circ = circle3d(c, [0, 0, 0, 1], 2.0; strokeColor="red")
```
"""
circle3d(center, normal, radius; kwargs...) =
    _create_element("circle3d", (center, normal, radius), kwargs)

"""
$(SIGNATURES)

Create a 3D polygon from a sequence of 3D points.

# Arguments
- `points...`: three or more Point3D elements

# Example
```julia
p1 = point3d(0, 0, 0)
p2 = point3d(1, 0, 0)
p3 = point3d(1, 1, 0)
p4 = point3d(0, 1, 0)
poly = polygon3d(p1, p2, p3, p4; fillColor="yellow", fillOpacity=0.3)
```
"""
polygon3d(points...; kwargs...) = _create_element("polygon3d", points, kwargs)

"""
$(SIGNATURES)

Create a 3D plane from a point and two direction vectors.

# Arguments
- `point`: a point on the plane (Point3D element)
- `dir1`: first spanning direction vector `[dx, dy, dz]`
- `dir2`: second spanning direction vector `[dx, dy, dz]`
- `range_u`: optional parameter range for first direction (default: unbounded)
- `range_v`: optional parameter range for second direction (default: unbounded)

# Example
```julia
p = point3d(0, 0, 0)
plane = plane3d(p, [1, 0, 0], [0, 1, 0], [-2, 2], [-2, 2];
    fillColor="blue", fillOpacity=0.2)
```
"""
function plane3d(point, dir1, dir2; range_u=nothing, range_v=nothing, kwargs...)
    parents = Any[point, dir1, dir2]
    if range_u !== nothing
        push!(parents, collect(range_u))
    end
    if range_v !== nothing
        push!(parents, collect(range_v))
    end
    return _create_element("plane3d", Tuple(parents), kwargs)
end

"""
$(SIGNATURES)

Create a 3D plane from three points.

# Example
```julia
p1 = point3d(0, 0, 0)
p2 = point3d(1, 0, 0)
p3 = point3d(0, 1, 0)
plane = plane3d(p1, p2, p3; fillColor="green", fillOpacity=0.2)
```
"""
function plane3d(p1::JSXElement, p2::JSXElement, p3::JSXElement; kwargs...)
    return _create_element("plane3d", (p1, p2, p3), pairs((; kwargs..., threePoints=true)))
end

"""
$(SIGNATURES)

Create a 3D intersection line of two planes.

# Arguments
- `plane1`: first Plane3D element
- `plane2`: second Plane3D element

# Example
```julia
p = point3d(0, 0, 0)
pl1 = plane3d(p, [1, 0, 0], [0, 1, 0]; range_u=(-3, 3), range_v=(-3, 3))
pl2 = plane3d(p, [1, 0, 1], [0, 1, 0]; range_u=(-3, 3), range_v=(-3, 3))
il = intersectionline3d(pl1, pl2; strokeColor="red")
```
"""
intersectionline3d(plane1, plane2; kwargs...) =
    _create_element("intersectionline3d", (plane1, plane2), kwargs)

"""
$(SIGNATURES)

Create a 3D intersection circle of two spheres or a sphere and a plane.

# Arguments
- `el1`: first element (Sphere3D or Plane3D)
- `el2`: second element (Sphere3D or Plane3D)

# Example
```julia
c1 = point3d(-1, 0, 0)
c2 = point3d(1, 0, 0)
s1 = sphere3d(c1, 2.0)
s2 = sphere3d(c2, 2.0)
ic = intersectioncircle3d(s1, s2; strokeColor="purple")
```
"""
intersectioncircle3d(el1, el2; kwargs...) =
    _create_element("intersectioncircle3d", (el1, el2), kwargs)

"""
$(SIGNATURES)

Create a 3D text label at position `(x, y, z)`.

# Arguments
- `x`, `y`, `z`: 3D coordinates for the text position
- `txt`: text content (String)

# Example
```julia
t = text3d(1, 2, 3, "Hello 3D"; fontSize=20)
```
"""
text3d(x, y, z, txt; kwargs...) =
    _create_element("text3d", (x, y, z, txt), kwargs)

"""
$(SIGNATURES)

Create a 3D wireframe mesh grid.

# Arguments
- `point`: origin point as `[x, y, z]` array or Point3D element
- `dir1`: first spanning direction vector `[dx, dy, dz]`
- `dir2`: second spanning direction vector `[dx, dy, dz]`
- `range1`: range along first direction `[min, max]`
- `range2`: range along second direction `[min, max]`

# Example
```julia
m = mesh3d([0, 0, 0], [1, 0, 0], [0, 1, 0], [-3, 3], [-3, 3];
    stepWidthU=1, stepWidthV=1)
```
"""
mesh3d(point, dir1, dir2, range1, range2; kwargs...) =
    _create_element("mesh3d", (point, dir1, dir2, range1, range2), kwargs)

"""
$(SIGNATURES)

Create a 3D polyhedron from vertices and face definitions.

JSXGraph renders each face with shading based on the camera angle.

# Arguments
- `vertices`: array of `[x, y, z]` coordinate arrays, or Point3D elements
- `faces`: array of faces, where each face is an array of vertex indices (0-based)

# Example
```julia
# Tetrahedron
verts = [[0, 0, 0], [2, 0, 0], [1, 2, 0], [1, 1, 2]]
faces = [[0, 1, 2], [0, 1, 3], [1, 2, 3], [0, 2, 3]]
p = polyhedron3d(verts, faces; fillOpacity=0.8)
```
"""
polyhedron3d(vertices, faces; kwargs...) =
    _create_element("polyhedron3d", (vertices, faces), kwargs)
