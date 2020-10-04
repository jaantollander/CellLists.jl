using Test, Logging, Random
using CellLists

@inline function distance_condition(p1::Vector{T}, p2::Vector{T}, r::T) where T <: AbstractFloat
    sum((p1 .- p2).^2) ≤ r^2
end

function brute_force(p::Array{T, 2}, r::T) where T <: AbstractFloat
    ps = Vector{Tuple{Int, Int}}()
    n, d = size(p)
    for i in 1:(n-1)
        for j in (i+1):n
            if distance_condition(p[i, :], p[j, :], r)
                push!(ps, (i, j))
            end
        end
    end
    return ps
end

function cell_list(p::Array{T, 2}, r::T) where T <: AbstractFloat
    ps = Vector{Tuple{Int, Int}}()
    c = CellList(p, r)
    for (i, j) in near_neighbors(c)
        if distance_condition(p[i, :], p[j, :], r)
            push!(ps, (i, j))
        end
    end
    return ps
end

function test_correctness(rng::AbstractRNG, ns::Vector{Int}, ds::Vector{Int}, rs::Vector{<:AbstractFloat}, iterations::Int)
    for (n, d, r) in Iterators.product(ns, ds, rs)
        @info "Testing: n: $n | d: $d | r: $r"
        for i in 1:iterations
            p = 2 .* rand(rng, n, d) .- 1.0
            a = Set(Set.(brute_force(p, r)))
            b = Set(Set.(cell_list(p, r)))
            @test b == a
        end
    end
end

const rng = MersenneTwister(894)
const ns = [1, 2, 10, 100]
const ds = [1, 2, 3]
const rs = [0.1, 0.2, 0.5, 1.0]
test_correctness(rng, ns, ds, rs, 20)
