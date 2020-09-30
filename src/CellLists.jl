module CellLists

"""Compute differences to neighboring cell in CartesianIndices."""
@inline function neighbors(d::Int)
    n = CartesianIndices(((-1:1 for _ in 1:d)...,))
    return n[1:fld(length(n), 2)]
end

"""CellList type."""
struct CellList{N}
    indices::Dict{CartesianIndex{N}, Vector{Int}}
    neighbors::Vector{CartesianIndex{N}}
end

function CellList(p::Array{T, 2}, r::T) where T <: AbstractFloat
    @assert r > 0
    n, d = size(p)
    cells = @. Int(fld(p, r))
    indices = Dict{CartesianIndex{d}, Vector{Int}}()
    for j in 1:n
        cell = CartesianIndex(cells[j, :]...)
        if cell in keys(indices)
            push!(indices[cell], j)
        else
            indices[cell] = [j]
        end
    end
    CellList{d}(indices, neighbors(d))
end

function near_neighbors(c::CellList)
    ps = Vector{Tuple{Int, Int}}()
    # Iterate over non-empty cells
    for (cell, is) in c.indices
        # Pairs of points within the cell
        for (k, i) in enumerate(is[1:(end-1)])
            for j in is[(k+1):end]
                push!(ps, (i, j))
            end
        end
        # Pairs of points with (non-empty) neighboring cells
        for neigh in c.neighbors
            if (cell + neigh) in keys(c.indices)
                js = c.indices[cell + neigh]
                for i in is, j in js
                    push!(ps, i < j ? (i, j) : (j, i))
                end
            end
        end
    end
    return ps
end

export CellList, near_neighbors

end # module
