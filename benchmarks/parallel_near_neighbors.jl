using Base.Threads
using Random
using BenchmarkTools
using CellLists

function benchmark(rng::AbstractRNG, n::Int, d::Int, r::Float64, iterations::Int; seconds::Float64)
    @info "" nthreads()
    ts = BenchmarkTools.Trial[]
    tp = BenchmarkTools.Trial[]
    for i in 1:iterations
        @info "" i
        p = rand(rng, n, d)
        c = CellList(p, r)
        bs = @benchmark near_neighbors($c, $p, $r) seconds=seconds
        bp = @benchmark p_near_neighbors($c, $p, $r) seconds=seconds
        push!(ts, bs)
        push!(tp, bp)
    end
    return ts, tp
end

rng = MersenneTwister(10)
iterations = 10
n = 20000
d = 2
r = 0.01
ts, tp = benchmark(rng, n, d, r, iterations; seconds=5.0)

# --- Figures ---

function figure_directory(name::AbstractString; fig_dir::AbstractString="figures")
    directory = joinpath(fig_dir, string(now()), name)
    if !ispath(directory)
        mkpath(directory)
    end
    return directory
end

using Plots

# minimum and median times and ratios
gettime(x) = getfield(x, :time)
ms = median.(ts)
mp = median.(tp)

p1 = plot(legend=false)
bar!(p1, gettime.(ms))
bar!(p1, gettime.(mp))

rsp = ratio.(ms, mp)
rt = gettime.(rsp)
p2 = scatter(rt)
plot!(p2, 1:length(rt), fill(mean(rt), length(rt)))

directory = figure_directory("parallel_near_neighbors")
savefig(p1, joinpath(directory, "d$d-r$r-n$n.svg"))
savefig(p2, joinpath(directory, "d$d-r$r-n$n-ratio.svg"))
