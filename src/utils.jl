"""
$SIGNATURES

Internal function to check that two vectors have matching length.
"""
function check_dims(vec1, vec2)
    if length(vec1) != length(vec2)
        throw(DimensionMismatch("The vectors don't have the same length."))
    end
end

"""
$SIGNATURES

Internal function to unpack kwargs.
"""
dict(; kw...) = isempty(kw) ? nothing : LittleDict{Symbol,Any}(kw)

"""
$SIGNATURES

Check if a function has already been defined on the board and is available
by checking the current functions in reverse order. Note that you could fool
this system but it should be ok in most standard cases.
"""
function isdef(f, b)
    isnothing(b) && return false
    fl = findlast(fc -> fc.name == f.name, b.functions)
    isnothing(fl) && return false
    fc = b.functions[fl]
    return fc.s == f.s
end
