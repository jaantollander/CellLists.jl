using Base.Threads

"""Merge two `CellList{d}`s with same dimension `d`."""
function Base.merge(c1::CellList{d}, c2::CellList{d}) where d
    data = copy(c1.data)
    for (cell, is) in c2.data
        if haskey(data, cell)
            @inbounds append!(data[cell], is)
        else
            data[cell] = is
        end
    end
    CellList{d}(data)
end

"""Multi-threaded constructor for CellList."""
function CellList(p::Array{T, 2}, r::T, ::Val{:parallel}) where T <: AbstractFloat
    t = nthreads()
    n, d = size(p)
    cs = cumsum(fill(fld(n, t), t-1))
    parts = collect(enumerate(zip([0; cs], [cs; n])))
    res = Array{CellList{d}, 1}(undef, t)
    @threads for (i, (a, b)) in parts
        res[i] = CellList(p[(a+1):b, :], r, a)
    end
    return reduce(merge, res)
end
