using Test, Logging, Random
using CellLists

@inline function distance_condition(p1::Vector{Float64}, p2::Vector{Float64}, r::Float64)
    sum((p1 .- p2).^2) ≤ r^2
end

function brute(p::Array{Float64, 2}, r::Float64)
    ps = Vector{Tuple{Int, Int}}()
    n, d = size(p)
    js = 1:n
    for (k, j) in enumerate(js[1:(end-1)])
        for j′ in js[(k+1):end]
            if distance_condition(p[j, :], p[j′, :], r)
                push!(ps, (j, j′))
            end
        end
    end
    return ps
end

function cell_list(p::Array{Float64, 2}, r::Float64)
    ps = Vector{Tuple{Int, Int}}()
    c = CellList(p, r)
    for (j, j′) in near_neighbors(c)
        if distance_condition(p[j, :], p[j′, :], r)
            push!(ps, (j, j′))
        end
    end
    return ps
end

function test_correctness(rng::AbstractRNG, iterations::Int)
    ns = [1, 2, 10, 100]
    ds = [1, 2, 3]
    rs = [0.01, 0.033, 0.05, 0.1, 0.2, 0.5, 1.0]
    for (n, d, r) in Iterators.product(ns, ds, rs)
        @info "Testing: n: $n | d: $d | r: $r"
        for i in 1:iterations
            p = 2 .* rand(rng, n, d) .- 1.0
            @test Set(brute(p, r)) == Set(cell_list(p, r))
        end
    end
end

rng = MersenneTwister(894)
test_correctness(rng, 100)
