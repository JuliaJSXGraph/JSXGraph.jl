# Julia-to-JavaScript conversion

"""
Mapping of Julia math function names to JavaScript `Math.*` equivalents.
"""
const MATH_FUNCTIONS = Dict{Symbol,String}(
    :sin => "Math.sin",
    :cos => "Math.cos",
    :tan => "Math.tan",
    :asin => "Math.asin",
    :acos => "Math.acos",
    :atan => "Math.atan",
    :sinh => "Math.sinh",
    :cosh => "Math.cosh",
    :tanh => "Math.tanh",
    :exp => "Math.exp",
    :log => "Math.log",
    :log10 => "Math.log10",
    :log2 => "Math.log2",
    :sqrt => "Math.sqrt",
    :abs => "Math.abs",
    :floor => "Math.floor",
    :ceil => "Math.ceil",
    :round => "Math.round",
    :sign => "Math.sign",
    :min => "Math.min",
    :max => "Math.max",
)

"""
Mapping of Julia math constants to JavaScript equivalents.
"""
const MATH_CONSTANTS = Dict{Symbol,String}(
    :pi => "Math.PI", :π => "Math.PI", :ℯ => "Math.E"
)

"""
Mapping of known Julia math functions (as `Function` objects) to their symbol names.
"""
const FUNCTION_TO_SYMBOL = Dict{Function,Symbol}(
    sin => :sin,
    cos => :cos,
    tan => :tan,
    asin => :asin,
    acos => :acos,
    atan => :atan,
    sinh => :sinh,
    cosh => :cosh,
    tanh => :tanh,
    exp => :exp,
    log => :log,
    log10 => :log10,
    log2 => :log2,
    sqrt => :sqrt,
    abs => :abs,
    floor => :floor,
    ceil => :ceil,
    round => :round,
    sign => :sign,
    min => :min,
    max => :max,
)

"""
$(SIGNATURES)

Convert a Julia expression to a JavaScript string.

Handles arithmetic operators, math functions (→ `Math.*`), power (→ `Math.pow`),
constants (π → `Math.PI`), and lambda expressions.
"""
function julia_to_js(expr::Expr)
    if expr.head == :call
        return _call_to_js(expr)
    elseif expr.head == :->
        return _lambda_to_js(expr)
    elseif expr.head == :block
        # Strip LineNumberNodes, convert last expression
        exprs = filter(e -> !(e isa LineNumberNode), expr.args)
        return julia_to_js(exprs[end])
    else
        return string(expr)
    end
end

function julia_to_js(s::Symbol)
    if haskey(MATH_CONSTANTS, s)
        return MATH_CONSTANTS[s]
    end
    return string(s)
end

function julia_to_js(n::Number)
    return string(n)
end

function julia_to_js(x::QuoteNode)
    return julia_to_js(x.value)
end

"""
$(SIGNATURES)

Convert a Julia `Function` to a JavaScript function string.

For known math functions (sin, cos, etc.), produces `function(x){return Math.sin(x);}`.
"""
function julia_to_js(f::Function)
    if haskey(FUNCTION_TO_SYMBOL, f)
        sym = FUNCTION_TO_SYMBOL[f]
        js_name = MATH_FUNCTIONS[sym]
        return "function(x){return $(js_name)(x);}"
    end
    error("Cannot convert unknown function $(f) to JavaScript. Use an expression instead.")
end

const INFIX_OPS = Set([:+, :-, :*, :/, :%])

function _call_to_js(expr::Expr)
    func = expr.args[1]

    # Power → Math.pow
    if func == :^
        base = julia_to_js(expr.args[2])
        exp = julia_to_js(expr.args[3])
        return "Math.pow($(base), $(exp))"
    end

    # Unary minus
    if func == :- && length(expr.args) == 2
        arg = julia_to_js(expr.args[2])
        return "-$(arg)"
    end

    # Infix operators
    if func isa Symbol && func in INFIX_OPS
        args_js = [julia_to_js(a) for a in expr.args[2:end]]
        return join(args_js, " $(func) ")
    end

    # Math functions
    if func isa Symbol && haskey(MATH_FUNCTIONS, func)
        js_func = MATH_FUNCTIONS[func]
        args_js = [julia_to_js(a) for a in expr.args[2:end]]
        return "$(js_func)($(join(args_js, ", ")))"
    end

    # Generic function call
    args_js = [julia_to_js(a) for a in expr.args[2:end]]
    return "$(func)($(join(args_js, ", ")))"
end

function _lambda_to_js(expr::Expr)
    params = expr.args[1]
    body = expr.args[2]

    # Handle single parameter
    param_str = if params isa Symbol
        string(params)
    elseif params isa Expr && params.head == :tuple
        join([string(p) for p in params.args], ", ")
    else
        string(params)
    end

    body_js = julia_to_js(body)
    return "function($(param_str)){return $(body_js);}"
end

# --- Unsupported construct detection (REQ-JSF-002) ---

"""
Set of expression heads that cannot be transpiled to JavaScript.
"""
const UNSUPPORTED_EXPR_HEADS = Set([
    :try,           # try/catch
    :for,           # for loops
    :while,         # while loops
    :comprehension, # array comprehensions
    :generator,     # generator expressions
    :struct,        # type definitions
    :macro,         # macro definitions
    :module,        # module definitions
    :import,        # import statements
    :using,         # using statements
    :export,        # export statements
    :let,           # let blocks
    :do,            # do blocks
])

"""
$(SIGNATURES)

Validate that a Julia expression can be transpiled to JavaScript.

Recursively walks the AST and throws an error if any unsupported construct
is found (e.g., try/catch, loops, comprehensions, multiple dispatch).
"""
function _validate_jsf(expr)
    if expr isa Expr
        if expr.head in UNSUPPORTED_EXPR_HEADS
            throw(ArgumentError(
                "Unsupported Julia construct `$(expr.head)` cannot be transpiled to JavaScript. " *
                "@jsf supports: arithmetic, math functions, comparisons, ifelse, and lambdas."
            ))
        end
        # Check for multi-line function bodies (multiple statements)
        if expr.head == :block
            stmts = filter(e -> !(e isa LineNumberNode), expr.args)
            if length(stmts) > 1
                throw(ArgumentError(
                    "Multi-statement function bodies are not supported by @jsf. " *
                    "Use a single expression instead."
                ))
            end
        end
        # Recurse into children
        for arg in expr.args
            _validate_jsf(arg)
        end
    end
    return nothing
end

# --- @jsf macro (REQ-JSF-001) ---

"""
    @jsf expression

Transpile a Julia mathematical expression into a [`JSFunction`](@ref) object
containing equivalent JavaScript code.

Supports arithmetic operators, `^` (power), comparison operators, ternary
`ifelse`, standard math functions (`sin`, `cos`, `tan`, `exp`, `log`, `sqrt`,
`abs`, `floor`, `ceil`, `min`, `max`, `pi`), and anonymous functions.

# Examples
```julia
# Anonymous function → JSFunction
f = @jsf x -> sin(x) + x^2

# Use directly in element constructors
fg = functiongraph(@jsf x -> cos(x) * exp(-x))

# Multi-argument function
g = @jsf (x, y) -> x^2 + y^2
```

If the expression contains unsupported Julia constructs (e.g., `try/catch`,
`for` loops, array comprehensions), a compile-time error is raised.
"""
macro jsf(expr)
    _validate_jsf(expr)
    js_code = julia_to_js(expr)
    return :(JSFunction($js_code))
end

# --- Named JSFunctions and transitive dependency resolution (REQ-GEO-012) ---

"""
$(SIGNATURES)

Create a *named* [`JSFunction`](@ref) from an existing (anonymous) one.

Named functions are emitted as `function name(...){...}` declarations in the
generated JavaScript, so that other `JSFunction` objects can reference them
by name.

# Examples
```julia
square = named_jsf(:square, @jsf(x -> x^2))
```
"""
function named_jsf(name::Symbol, f::JSFunction)
    return JSFunction(f.code, string(name), f.deps)
end

"""
$(SIGNATURES)

Return a copy of `f` with the given named [`JSFunction`](@ref) dependencies
attached.  The rendering pipeline uses this information to emit named helper
function definitions (in topological order) before the code that calls them.

# Examples
```julia
square = named_jsf(:square, @jsf(x -> x^2))
shifted = with_deps(@jsf(x -> square(x) + 1), square)
```
"""
function with_deps(f::JSFunction, deps::JSFunction...)
    return JSFunction(f.code, f.name, collect(JSFunction, deps))
end

"""
    @named_jsf name(args...) = body

Syntactic sugar for creating a *named* [`JSFunction`](@ref).

Equivalent to `name = named_jsf(:name, @jsf(args -> body))`.

# Examples
```julia
@named_jsf square(x) = x^2
@named_jsf avg(a, b) = (a + b) / 2
```
"""
macro named_jsf(expr)
    if !(expr isa Expr && expr.head == :(=) &&
         expr.args[1] isa Expr && expr.args[1].head == :call)
        throw(ArgumentError(
            "@named_jsf expects syntax: @named_jsf name(args...) = body"
        ))
    end

    call_expr = expr.args[1]
    name = call_expr.args[1]  # Symbol (:square)
    params = call_expr.args[2:end]  # [:x] or [:a, :b]
    body = expr.args[2]

    # Build an equivalent lambda expression for validation + transpilation
    lambda = if length(params) == 1
        Expr(:->, params[1], body)
    else
        Expr(:->, Expr(:tuple, params...), body)
    end

    _validate_jsf(lambda)
    js_code = julia_to_js(lambda)
    name_str = string(name)

    return :($(esc(name)) = JSFunction($js_code, $name_str, JSFunction[]))
end

# --- Transitive dependency collection ---

"""
Collect all transitive named [`JSFunction`](@ref) dependencies from a board's
elements, returned in topological (definition) order.
"""
function collect_jsf_deps(board::Board)
    visited = Set{String}()
    result = JSFunction[]
    for elem in board.elements
        for parent in elem.parents
            _collect_jsf_from_parent!(result, visited, parent)
        end
    end
    return result
end

function _collect_jsf_from_parent!(result, visited, f::JSFunction)
    _collect_deps_recursive!(result, visited, f)
end

function _collect_jsf_from_parent!(result, visited, v::AbstractVector)
    for item in v
        _collect_jsf_from_parent!(result, visited, item)
    end
end

function _collect_jsf_from_parent!(result, visited, t::Tuple)
    for item in t
        _collect_jsf_from_parent!(result, visited, item)
    end
end

function _collect_jsf_from_parent!(result, visited, @nospecialize(x))
    # Non-JSFunction, non-collection parent — nothing to do
    return nothing
end

function _collect_deps_recursive!(result, visited, f::JSFunction)
    for dep in f.deps
        if !isempty(dep.name) && dep.name ∉ visited
            _collect_deps_recursive!(result, visited, dep)
            push!(visited, dep.name)
            push!(result, dep)
        end
    end
end

