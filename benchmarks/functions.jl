using BenchmarkTools
using CellLists

@inline function distance_condition(p1::Vector{T}, p2::Vector{T}, r::T) where T <: AbstractFloat
    sum(@. (p1 - p2)^2) ≤ r^2
end

# --- Algorithms ---

@noinline function brute_force(p::Array{T, 2}, r::T) where T <: AbstractFloat
    n, d = size(p)
    for i in 1:(n-1)
        for j in (i+1):n
            distance_condition(p[i, :], p[j, :], r)
        end
    end
end

@noinline function cell_list(p::Array{T, 2}, r::T) where T <: AbstractFloat
    c = CellList(p, r)
    for (i, j) in near_neighbors(c)
        distance_condition(p[i, :], p[j, :], r)
    end
end

# --- Benchmarking ---

function benchmark(algorithm::Function, p::Array{T, 2}, r::T) where T <: AbstractFloat
    b = @benchmarkable $algorithm($p, $r) samples=500 seconds=0.5
    run(b)
end

function benchmarks(algorithm::Function, ps::Vector{Array{T, 2}}, r::T) where T <: AbstractFloat
    [median(benchmark(algorithm, p, r)) for p in ps]
end
