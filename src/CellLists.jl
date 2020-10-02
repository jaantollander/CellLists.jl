module CellLists

export CellList, near_neighbors

"""CellList type. The `indices` dictionary maps the `CartesianIndex` of each cell to the indices of points in that cell.
"""
struct CellList{d}
    indices::Dict{CartesianIndex{d}, Vector{Int}}
end

"""Construct CellList from points `p` and radius `r>0`.

# Examples
```julia
n, d, r = 100, 2, 0.01
p = rand(n, d)
c = CellLists(p, r)
```
"""
function CellList(p::Array{T, 2}, r::T) where T <: AbstractFloat
    @assert r > 0
    n, d = size(p)
    cells = @. Int(fld(p, r))
    indices = Dict{CartesianIndex{d}, Vector{Int}}()
    for j in 1:n
        cell = CartesianIndex(cells[j, :]...)
        if haskey(indices, cell)
            push!(indices[cell], j)
        else
            indices[cell] = [j]
        end
    end
    CellList{d}(indices)
end

"""Compute offsets to neighboring cells in `d` dimensions."""
@inline function neighbors(d::Int)
    n = CartesianIndices((fill(-1:1, d)...,))
    return n[1:fld(length(n), 2)]
end

"""Return a vector of all pairs that are in neighboring cells in the cell list.

# Examples
```julia-repl
julia> near_neighbors(c)
[(1, 4), (3, 11), ...]
```
"""
function near_neighbors(c::CellList{d}) where d
    ps = Vector{Tuple{Int, Int}}()
    offsets = neighbors(d)
    # Iterate over non-empty cells
    for (cell, is) in c.indices
        # Pairs of points within the cell
        for (k, i) in enumerate(is[1:(end-1)])
            for j in is[(k+1):end]
                push!(ps, (i, j))
            end
        end
        # Pairs of points with non-empty neighboring cells
        for offset in offsets
            if haskey(c.indices, cell + offset)
                js = c.indices[cell + offset]
                for i in is, j in js
                    push!(ps, i < j ? (i, j) : (j, i))
                end
            end
        end
    end
    return ps
end

end # module
