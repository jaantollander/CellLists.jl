"""CellList type. The `indices` dictionary maps the `CartesianIndex` of each cell to the indices of points in that cell.
"""
struct CellList{d}
    data::Dict{CartesianIndex{d}, Vector{Int}}
end

"""Construct CellList from points `p` and radius `r>0`.

# Examples
```julia
n, d, r = 100, 2, 0.01
p = rand(n, d)
c = CellLists(p, r)
```
"""
function CellList(p::Array{T, 2}, r::T; offset::Int=0) where T <: AbstractFloat
    @assert r > 0
    n, d = size(p)
    cells = @. Int(fld(p, r))
    data = Dict{CartesianIndex{d}, Vector{Int}}()
    for j in 1:n
        @inbounds cell = CartesianIndex(cells[j, :]...)
        if haskey(data, cell)
            @inbounds push!(data[cell], j + offset)
        else
            data[cell] = [j + offset]
        end
    end
    CellList{d}(data)
end

"""Compute offsets to neighboring cells in `d` dimensions."""
@inline function neighbors(d::Int)
    n = CartesianIndices((fill(-1:1, d)...,))
    return n[1:fld(length(n), 2)]
end

@inline function distance_condition(p1::Vector{T}, p2::Vector{T}, r::T) where T <: AbstractFloat
    sum(@. (p1 - p2)^2) ≤ r^2
end

@inline function brute_force!(ps::Vector{Tuple{Int, Int}}, is::Vector{Int}, p::Array{T, 2}, r::T) where T <: AbstractFloat
    for (k, i) in enumerate(is[1:(end-1)])
        for j in is[(k+1):end]
            if @inbounds distance_condition(p[i, :], p[j, :], r)
                push!(ps, (i, j))
            end
        end
    end
end

@inline function brute_force!(ps::Vector{Tuple{Int, Int}}, is::Vector{Int}, js::Vector{Int}, p::Array{T, 2}, r::T) where T <: AbstractFloat
    for i in is
        for j in js
            if @inbounds distance_condition(p[i, :], p[j, :], r)
                push!(ps, (i, j))
            end
        end
    end
end

"""Return a vector of all pairs that are in neighboring cells in the cell list.

# Examples
```julia-repl
julia> near_neighbors(c, p, r)
[(1, 4), (3, 11), ...]
```
"""
function near_neighbors(c::CellList{d}, p::Array{T, 2}, r::T) where d where T <: AbstractFloat
    ps = Vector{Tuple{Int, Int}}()
    offsets = neighbors(d)
    # Iterate over non-empty cells
    for (cell, is) in c.data
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
