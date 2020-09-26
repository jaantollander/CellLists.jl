module CellLists

export CellList, cell_indices, near_neighbors

"""Compute differences to neighboring cell in CartesianIndices."""
function neighbors(d::Int)
    n = CartesianIndices(((-1:1 for _ in 1:d)...,))
    return n[1:fld(length(n), 2)]
end

"""CellList type."""
struct CellList{N}
    indices::Vector{Int}
    counts::Array{Int, N}
    offsets::Array{Int, N}
    neighbors::Vector{CartesianIndex{N}}
end

"""Construct CellList for `d`-dimensional points `p` and radius `r>0`.

## Examples
```julia
p = rand(10, 2)
c = CellList(p, 0.1)
```
"""
function CellList(p::Array{T, 2}, r::T) where T <: AbstractFloat
    @assert r > 0
    n, d = size(p)

    x = @. Int(fld(p, r))
    x_min = minimum(x, dims=1)
    x_max = maximum(x, dims=1)
    cells = @. (x - x_min + 2)
    shape = @. (x_max - x_min + 3)

    # Number of points per cell
    counts = zeros(Int, shape...)
    for j in 1:n
        cell = cells[j, :]
        counts[cell...] += 1
    end

    # Sort the points by the order in cells
    offsets = reshape(cumsum(vec(counts)), size(counts))
    indices = zeros(Int, n)
    # Iterate points in reversed order j in n:-1:1,
    # then output of cell_indices(c, cell) is sorted.
    for j in n:-1:1
        cell = cells[j, :]
        k = offsets[cell...]
        indices[k] = j
        offsets[cell...] -= 1
    end

    CellList(indices, counts, offsets, neighbors(d))
end

"""Return indices of points in `cell`. Guaranteed to be in sorted order."""
function cell_indices(c::CellList, cell::CartesianIndex)
    a = c.offsets[cell]
    b = a + c.counts[cell]
    return c.indices[(a+1):b]
end

"""Returns vector of index pairs of points that are near neighbors.

## Examples
```julia-repl
julia> near_neighbors(c)
[(3, 6), (4, 5)]
```
"""
function near_neighbors(c::CellList)
    ps = Vector{Tuple{Int, Int}}()

    for cell in CartesianIndices(c.counts)
        if iszero(c.counts[cell])
            continue
        end

        # Points in the current cell
        is = cell_indices(c, cell)

        # Pairs of points within the cell
        for (k, i) in enumerate(is[1:(end-1)])
            for j in is[(k+1):end]
                push!(ps, (i, j))
            end
        end

        # Pairs of points with neighboring cells
        for neigh in c.neighbors
            js = cell_indices(c, cell + neigh)
            for i in is, j in js
                if i < j
                    push!(ps, (i, j))
                else
                    push!(ps, (j, i))
                end
            end
        end
    end

    return ps
end

end # module
