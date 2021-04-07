using Base.Threads
import Base.Threads.@spawn

"""Merge two `CellList{d}`s with same dimension `d`.

# Examples
```julia
n, d, r = 100, 2, 0.01
p = (rand(n, d), rand(n, d))
merge(CellList(p[1], r), CellList(p[2], r))
```
"""
function Base.merge(c1::CellList{d}, c2::CellList{d}) where d
    CellList{d}(merge(vcat, c1.data, c2.data))
end

"""Multi-threaded constructor for CellList.

# Examples
```julia
n, d, r = 100, 2, 0.01
p = rand(n, d)
c = CellList(p, r, Val(:parallel))
```
"""
function CellList(p::Array{T, 2}, r::T, ::Val{:parallel}) where T <: AbstractFloat
    t = nthreads()
    n, d = size(p)
    cs = cumsum(fill(fld(n, t), t-1))
    parts = zip([0; cs], [cs; n])
    res = Array{CellList{d}, 1}(undef, t)
    @threads for (i, (a, b)) in collect(enumerate(parts))
        res[i] = CellList(p[(a+1):b, :], r, a)
    end
    return reduce(merge, res)
end

function brute_force_cell!(pts, cell, is, p, r, data, offsets)
    # Pairs of points within the cell
    brute_force!(pts[threadid()], is, p, r)
    # Pairs of points with non-empty neighboring cells
    for offset in offsets
        neigh_cell = cell + offset
        if haskey(data, neigh_cell)
            @inbounds js = data[neigh_cell]
            brute_force!(pts[threadid()], is, js, p, r)
        end
    end
end

"""Parallel near neighbors"""
function near_neighbors(c::CellList{d}, p::Array{T, 2}, r::T, ::Val{:parallel}) where d where T <: AbstractFloat
    offsets = neighbors(d)
    pts = [Vector{Tuple{Int, Int}}() for _ in 1:nthreads()]
    data = collect(c.data)
    perm = sortperm(@. length(getfield(data, 2)))
    # Iterate over non-empty cells in decreasing order of points per cell
    @sync for (cell, is) in reverse(data[perm])
        @spawn brute_force_cell!(pts, cell, is, p, r, c.data, offsets)
    end
    return reduce(vcat, pts)
end
