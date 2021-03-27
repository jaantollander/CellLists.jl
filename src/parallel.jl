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

function greedy_partition(m::Vector{Int}, n::Int)
    # Put largest item to subset of the smallest size.
    sizes = zeros(Int, n)
    subsets = [Vector{Int}() for _ in 1:n]
    for i in reverse(sortperm(m))
        _, j = findmin(sizes)
        sizes[j] += m[i]
        push!(subsets[j], i)
    end
    return subsets
end

function near_neighbors_part(c::CellList{d}, data::Vector{Pair{CartesianIndex{d}, Vector{Int}}}, p::Array{T, 2}, r::T, offsets::Vector{CartesianIndex{d}}) where d where T <: AbstractFloat
    ps = Vector{Tuple{Int, Int}}()
    for (cell, is) in data
        # Pairs of points within the cell
        brute_force!(ps, is, p, r)
        # Pairs of points with non-empty neighboring cells
        for offset in offsets
            neigh_cell = cell + offset
            if haskey(c.data, neigh_cell)
                @inbounds js = c.data[neigh_cell]
                brute_force!(ps, is, js, p, r)
            end
        end
    end
    return ps
end

"""Parallel near neighbors

# Examples
```julia
p_near_neighbors(c, p, r; t=3*nthreads())
```
"""
function p_near_neighbors(c::CellList{d}, p::Array{T, 2}, r::T; t::Int=nthreads()) where d where T <: AbstractFloat
    @assert t ≥ 1
    offsets = neighbors(d)
    data = collect(c.data)
    subsets = greedy_partition(@.(length(values(data))^2), t)
    tasks = Array{Task}(undef, t)
    @sync for (i, subset) in collect(enumerate(subsets))
        @async tasks[i] = @spawn near_neighbors_part(c, data[subset], p, r, offsets)
    end
    pts = fetch.(tasks)
    return reduce(vcat, pts)
end
