module CellLists

export CellList, near_neighbors

"""Compute differences to neighboring cell in CartesianIndices."""
function neighbors(d::Int)
    r = [UnitRange(-1, 1) for _ in 1:d]
    p = vec(collect(Iterators.product(r...)))
    is = p[1:div(length(p), 2)]
    return [CartesianIndex(i...) for i in is]
end

"""CellList type."""
struct CellList{N}
    indices::Vector{Int}
    count::Array{Int, N}
    offset::Array{Int, N}
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
    x_ind = @. (x - x_min + 1 + 1)
    shape = vec(@. (x_max - x_min + 2 + 1))

    # Number of points per cell
    count = zeros(Int, shape...)
    for j in 1:n
        i = x_ind[j, :]
        count[i...] += 1
    end

    # Sort the points by the order in cells
    offset = reshape(cumsum(vec(count)), size(count))
    indices = zeros(Int, n)
    for j in 1:n
        i = x_ind[j, :]
        k = offset[i...]
        indices[k] = j
        offset[i...] -= 1
    end

    CellList(indices, count, offset, neighbors(d))
end

"""Query indices of points in cell `i`."""
function cell_indices(c::CellList, i::CartesianIndex)
    a = c.offset[i]
    b = a + c.count[i]
    return c.indices[(a+1):b]
end

"""Return elements `j` and `j′` as sorted pair."""
function sorted_pair(j::Int, j′::Int)
    if j < j′; (j, j′) else (j′, j) end
end

"""Returns vector of index pairs of points that are possible near neighbors.

## Examples
```julia-repl
julia> near_neighbors(c)
[(3, 6), (4, 5)]
```
"""
function near_neighbors(c::CellList)
    ps = Vector{Tuple{Int, Int}}()

    for i in CartesianIndices(c.count)
        if c.count[i] == 0
            continue
        end

        # Points in the current cell
        js = cell_indices(c, i)

        # Pairs of points within the cell
        for (k, j) in enumerate(js[1:(end-1)])
            for j′ in js[(k+1):end]
                push!(ps, sorted_pair(j, j′))
            end
        end

        # Pairs of points with neighboring cells
        for i′ in c.neighbors
            js′ = cell_indices(c, i+i′)
            for j in js, j′ in js′
                push!(ps, sorted_pair(j, j′))
            end
        end
    end

    return ps
end

end # module
