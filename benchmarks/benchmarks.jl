using Base.Threads
using Dates
using Random
using Plots
using BenchmarkTools
using ProgressMeter
using CellLists


# --- Algorithms ---

function brute_force(p::Array{T, 2}, r::T) where T <: AbstractFloat
    ps = Vector{Tuple{Int, Int}}()
    n, d = size(p)
    for i in 1:(n-1)
        for j in (i+1):n
            if @inbounds distance_condition(p[i, :], p[j, :], r)
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


# --- Benchmarking ---

@enum Measure time memory allocs

function distribution(trials::Vector{BenchmarkTools.Trial}, measure::Measure)
    getfield.(median.(trials), Symbol(measure))
end

function benchmarks(algorithm::Function, psn::Vector{Vector{Array{T, 2}}}, r::T, measure::Measure; samples=500, seconds=0.5) where T <: AbstractFloat
    data = zeros(length(psn), length(psn[1]))
    @showprogress for (i, ps) in enumerate(psn)
        trials = BenchmarkTools.Trial[]
        for p in ps
            t = run(@benchmarkable $algorithm($p, $r) samples=samples seconds=seconds)
            push!(trials, t)
        end
        data[i, :] = distribution(trials, measure)
    end
    return data
end


# --- Plots ---

function figure_directory(name::AbstractString; fig_dir::AbstractString="figures")
    directory = joinpath(fig_dir, string(now()), name)
    if !ispath(directory)
        mkpath(directory)
    end
    return directory
end

function plot_stats!(plt::Plots.Plot, x::Vector{<:Number}, y::Array{<:Number, 2}, name::String)
    plot!(plt, x, minimum(y, dims=2), markershape=:circle, markersize=1, linestyle=:dash, linecolor=:gray, label="")
    plot!(plt, x, maximum(y, dims=2), markershape=:circle, markersize=1, linestyle=:dash, linecolor=:gray, label="")
    plot!(plt, x, mean(y, dims=2), markershape=:circle, markersize=1, label="$name", linewidth=3)
    return plt
end

function cell_list_vs_brute_force(seed::Int, measure::Measure)
    instances = [
        (0.01, 2, [1, 5, collect(10:10:100)...]),
        (0.01, 3, [1, 5, collect(10:10:100)...]),
        (0.01, 4, [1, 5, collect(10:10:200)...]),
        (0.01, 5, [1, 5, collect(10:10:300)...]),
    ]

    for (r, d, ns) in instances
        @info "Inputs: r: $r, d: $d"
        rng = MersenneTwister(seed)
        psn1 = [[rand(rng, n, d) for _ in 1:10] for n in ns]

        @info "Benchmarking Cell List"
        cl = benchmarks(cell_list, psn1, r, measure)

        @info "Benchmarking Brute Force"
        psn2 = [psn[1:3] for psn in psn1]
        bf = benchmarks(brute_force, psn2, r, measure)

        plt = plot(title="$measure | r: $r, d: $d", size=(720, 480), legend=:topleft)
        plot_stats!(plt, ns, cl, "Cell List")
        plot_stats!(plt, ns, bf, "Brute Force")

        directory = figure_directory("cell_list_vs_brute_force")
        savefig(plt, joinpath(directory, "d$d-r$r-n$(ns[end]).svg"))
    end
end

function cell_list_dimensionality(seed::Int, measure::Measure)
    r = 0.05
    ds = [2, 3, 4, 5, 6]
    ns = [1, 10, 25, collect(50:50:1000)...]
    rng = MersenneTwister(seed)

    plt = plot(title="$measure | r: $r", size=(720, 480), legend=:topleft)
    for d in ds
        @info "Inputs: r: $r, d: $d"
        psn = [[rand(rng, n, d) for _ in 1:1] for n in ns]

        @info "Benchmarking Cell List"
        cl = benchmarks(cell_list, psn, r, measure)

        plot_stats!(plt, ns, cl, "Cell List d: $d")
    end

    directory = figure_directory("cell_list_dimensionality")
    savefig(plt, joinpath(directory, "r$r-n$(ns[end]).svg"))
end

function cell_list_constructor(seed::Int, measure::Measure)
    r = 0.1
    ds = [2]
    ns = [1, 10, 25, 35, 50, 75, collect(100:50:1000)...]
    rng = MersenneTwister(seed)
    iterations = 1

    for d in ds
        @info "Inputs: r: $r, d: $d"
        rng = MersenneTwister(seed)
        psn = [[rand(rng, n, d) for _ in 1:iterations] for n in ns]

        @info "Benchmarking CellList construtor serial"
        cl1 = benchmarks((p, r) -> CellList(p, r), psn, r, measure)

        @info "Benchmarking CellList construtor parallel"
        cl2 = benchmarks((p, r) -> CellList(p, r, Val(:parallel)), psn, r, measure)

        plt = plot(title="$measure | r: $r, d: $d", size=(720, 480), legend=:topleft)
        plot_stats!(plt, ns, cl1, "CellList serial")
        plot_stats!(plt, ns, cl2, "CellList parallel ($(nthreads()) threads)")

        ratio = cl1./cl2
        plt2 = plot(title="$measure ratio | r: $r, d: $d", size=(720, 480), legend=:bottomright,
                    xticks=0:100:maximum(ns),
                    yticks=round.(LinRange(min(1.0, minimum(ratio)), maximum(ratio), 15), digits=2))
        plot_stats!(plt2, ns, ratio, "ratio: serial/parallel ($(nthreads()) threads)")
        plot!(plt2, [minimum(ns), maximum(ns)], [1, 1], linestyle=:dash, alpha=0.5, linewidth=2, label="ratio: 1")

        directory = figure_directory("cell_list_parallel_constructor")
        savefig(plt, joinpath(directory, "d$d-r$r-n$(ns[end]).svg"))
        savefig(plt2, joinpath(directory, "d$d-r$r-n$(ns[end])-ratio.svg"))
    end
end
