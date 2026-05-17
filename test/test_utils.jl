function isapproxstr(s1::AbstractString, s2::AbstractString)
    isequal(map(s->replace(s, r"\s|\n"=>""), String.((s1, s2)))...)
end
