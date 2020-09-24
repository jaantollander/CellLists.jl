module CellLists

export CellList, near_neighbors

struct CellList
    indices::Vector{Int}
    shape::Vector{Int}
    count::Array{Int}
    offset::Array{Int}
end

function CellList(p::Array{Float64, 2}, r::Float64)
    @assert r > 0
    n, d = size(p)

    x = Int.(div.(p, r, RoundDown))
    x_min = minimum(x, dims=1)
    x_max = maximum(x, dims=1)
    x_ind = @. (x - x_min + 1 + 1)
    shape = vec(@. (x_max - x_min + 2 + 1)) # TODO: remove + 1?

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

    return CellList(indices, shape, count, offset)
end

function query(c::CellList, i::CartesianIndex)
    a = c.offset[i]
    b = a + c.count[i]
    return c.indices[(a+1):b]
end

function neighbors(dist::Int, d::Int)
    @assert dist>=1
    r = [UnitRange(-dist, dist) for _ in 1:d]
    p = vec(collect(Iterators.product(r...)))
    return [CartesianIndex(i...) for i in p[1:div(length(p), 2)]]
end

function near_neighbors(c::CellList)
    ps = Vector{Tuple{Int, Int}}()
    d = length(c.shape)
    neigh = neighbors(1, d)

    for i in CartesianIndices(c.count)
        if c.count[i] == 0
            continue
        end

        # Points in the current cell
        js = query(c, i)

        # Pairs of points within the cell
        for (k, j) in enumerate(js[1:(end-1)])
            for j′ in js[(k+1):end]
                push!(ps, (j, j′))
            end
        end

        # Pairs of points with neighboring cells
        for i′ in neigh
            js′ = query(c, i+i′)
            for j in js, j′ in js′
                push!(ps, (j, j′))
            end
        end
    end

    return ps
end

# TODO: interface, iterate

end # module
