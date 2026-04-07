# Attribute alias resolution for Plots.jl compatibility

"""
Mapping of Julia-friendly keyword aliases to JSXGraph attribute names.

Each entry maps an alias `Symbol` to a tuple of `(targets, priority)` where:
- `targets` is a `Vector{String}` of JSXGraph attribute names
- `priority` is `:full` (full-word alias) or `:short` (abbreviated alias)

Full-priority aliases take precedence over short-priority aliases.
JSXGraph-native attribute names always take precedence over any alias.
"""
const ATTRIBUTE_ALIASES = Dict{Symbol,Tuple{Vector{String},Symbol}}(
    # color aliases → strokeColor
    :color => (["strokeColor"], :full),
    :linecolor => (["strokeColor"], :full),
    :col => (["strokeColor"], :short),
    # linewidth aliases → strokeWidth
    :linewidth => (["strokeWidth"], :full),
    :lw => (["strokeWidth"], :short),
    # fillcolor aliases → fillColor
    :fillcolor => (["fillColor"], :full),
    :fill => (["fillColor"], :short),
    # opacity aliases → strokeOpacity + fillOpacity
    :opacity => (["strokeOpacity", "fillOpacity"], :full),
    :alpha => (["strokeOpacity", "fillOpacity"], :short),
    # linestyle aliases → dash
    :linestyle => (["dash"], :full),
    :ls => (["dash"], :short),
    # markersize aliases → size
    :markersize => (["size"], :full),
    :ms => (["size"], :short),
    # label alias → name
    :label => (["name"], :full),
    # legend alias → withLabel
    :legend => (["withLabel"], :full),
    # 3D surface-specific aliases
    :surfacecolor => (["fillColor"], :full),
    :surfaceopacity => (["fillOpacity"], :full),
    :wireframecolor => (["strokeColor"], :full),
    :wireframewidth => (["strokeWidth"], :full),
    :meshcolor => (["meshColor"], :full),
    :meshwidth => (["meshWidth"], :full),
)

"""
$(SIGNATURES)

Resolve Plots.jl-compatible keyword aliases to JSXGraph attribute names.

Processes keyword arguments in three passes:
1. Collect JSXGraph-native string keys (always take precedence)
2. Apply full-priority aliases (skip if target already set)
3. Apply short-priority aliases (skip if target already set)

Unrecognized keywords pass through unchanged.
"""
function resolve_aliases(kwargs)
    result = Dict{String,Any}()

    # Separate kwargs into: native JSXGraph keys, full aliases, short aliases
    full_aliases = Pair{Symbol,Any}[]
    short_aliases = Pair{Symbol,Any}[]

    for (k, v) in kwargs
        if haskey(ATTRIBUTE_ALIASES, k)
            _, priority = ATTRIBUTE_ALIASES[k]
            if priority == :full
                push!(full_aliases, k => v)
            else
                push!(short_aliases, k => v)
            end
        else
            # Not an alias — treat as JSXGraph-native or passthrough
            result[string(k)] = v
        end
    end

    # Apply full-priority aliases (skip if target already set by native key)
    for (k, v) in full_aliases
        targets, _ = ATTRIBUTE_ALIASES[k]
        for target in targets
            if !haskey(result, target)
                result[target] = v
            end
        end
    end

    # Apply short-priority aliases (skip if target already set by native or full alias)
    for (k, v) in short_aliases
        targets, _ = ATTRIBUTE_ALIASES[k]
        for target in targets
            if !haskey(result, target)
                result[target] = v
            end
        end
    end

    return result
end

"""
    color_to_css(c)

Convert a color value to a CSS color string.

No methods defined in the base module. JSXGraphColorsExt adds methods for
Colors.jl types (RGB, RGBA, HSL, etc.) when Colors.jl is loaded.
"""
function color_to_css end

"""
$(SIGNATURES)

Convert color values in attributes to CSS strings.

Iterates attribute values and converts any that have a `color_to_css` method
defined (added by JSXGraphColorsExt when Colors.jl is loaded).
"""
function convert_color_values(attrs::Dict{String,Any})
    for (k, v) in attrs
        if applicable(color_to_css, v)
            attrs[k] = color_to_css(v)
        end
    end
    return attrs
end
