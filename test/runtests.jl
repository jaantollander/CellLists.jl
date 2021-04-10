using Test
using Random
using CellLists

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
    c = CellList(p, r)
    return near_neighbors(c, p, r)
end

function test_sequential(rng::AbstractRNG, ns::Vector{Int}, ds::Vector{Int}, rs::Vector{<:AbstractFloat}, iterations::Int)
    for (n, d, r) in Iterators.product(ns, ds, rs)
        @info "Testing sequential: n: $n | d: $d | r: $r"
        for i in 1:iterations
            p = 2 .* rand(rng, n, d) .- 1.0
            a = Set(Set.(brute_force(p, r)))
            b = Set(Set.(cell_list(p, r)))
            @test b == a
        end
    end
end

function test_merge(rng::AbstractRNG, ns, ds, rs)
    for (n, d, r) in Iterators.product(ns, ds, rs)
        @info "Testing merge: n: $n | d: $d | r: $r"
        p = 2 .* rand(rng, n, d) .- 1.0
        l = fld(n, 2)
        c1 = CellList(p, r)
        c2 = CellList(p[1:l, :], r)
        c3 = CellList(p[(l+1):end, :], r, l)
        c4 = merge(c1, c2)
        @test Set(keys(c1.data)) == Set(keys(c4.data))
        for cell in keys(c1.data)
            @test Set(c1.data[cell]) == Set(c4.data[cell])
        end
    end
end

function test_parallel_constructor(rng::AbstractRNG, ns, ds, rs)
    for (n, d, r) in Iterators.product(ns, ds, rs)
        @info "Testing parallel constructor: n: $n | d: $d | r: $r"
        p = 2 .* rand(rng, n, d) .- 1.0
        c1 = CellList(p, r)
        c2 = CellList(p, r, Val(:threads))
        @test Set(keys(c1.data)) == Set(keys(c2.data))
        for cell in keys(c1.data)
            @test Set(c1.data[cell]) == Set(c2.data[cell])
        end
    end
end

function test_parallel_near_neighbors(rng::AbstractRNG, ns::Vector{Int}, ds::Vector{Int}, rs::Vector{<:AbstractFloat}, iterations::Int)
    for (n, d, r) in Iterators.product(ns, ds, rs)
        @info "Testing parallel: n: $n | d: $d | r: $r"
        for i in 1:iterations
            p = 2 .* rand(rng, n, d) .- 1.0
            c = CellList(p, r)
            a = near_neighbors(c, p, r)
            b = near_neighbors(c, p, r, Val(:threads))
            @test Set(Set.(b)) == Set(Set.(a))
        end
    end
end

function test_parallel_near_neighbors_large(rng::AbstractRNG, n::Int, d::Int, r::Float64)
    @info "Testing parallel: n: $n | d: $d | r: $r"
    p = 2 .* rand(rng, n, d) .- 1.0
    c = CellList(p, r)
    a = near_neighbors(c, p, r)
    b = near_neighbors(c, p, r, Val(:threads))
    @test Set(Set.(b)) == Set(Set.(a))
end

const rng = MersenneTwister(894)
const ns = [0, 1, 2, 10, 100]
const ds = [1, 2, 3]
const rs = [0.1, 0.2, 0.3, 0.5, 1.0, 2.0]
test_sequential(rng, ns, ds, rs, 20)
test_merge(rng, ns, ds, rs)
test_parallel_constructor(rng, ns, ds, rs)
test_parallel_near_neighbors(rng, ns, ds, rs, 20)
test_parallel_near_neighbors_large(rng, 20000, 2, 0.01)
test_parallel_near_neighbors_large(rng, 30000, 3, 0.01)
