using Random, Statistics, Plots
include("functions.jl")

@enum Measure time memory allocs

function stats(algorithm::Function, psn::Vector{Vector{Array{T, 2}}}, r::T, m::Measure) where T <: AbstractFloat
    data = zeros(length(psn), 3)
    for (i, ps) in enumerate(psn)
        @info "Instance: $i"
        bs = benchmarks(algorithm, ps, r)
        vals = [getfield(b, Symbol(m)) for b in bs]
        data[i, 1] = mean(vals)
        data[i, 2] = quantile(vals, 0.01)
        data[i, 3] = quantile(vals, 0.99)
    end
    return data
end

function plot_data!(plt::Plots.Plot, ns::Vector{Int}, data::Array{<:AbstractFloat, 2}, name::String)
    plot!(plt, ns, data[:, 2], markershape=:circle, markersize=1, linestyle=:dash, linecolor=:gray, label="")
    plot!(plt, ns, data[:, 3], markershape=:circle, markersize=1, linestyle=:dash, linecolor=:gray, label="")
    plot!(plt, ns, data[:, 1], markershape=:circle, markersize=1, label="$name", linewidth=3)
    return plt
end

function cell_list_vs_brute_force(seed::Int, measure::Measure)
    instances = [
        (0.01, 2, collect(10:10:100)),
        (0.01, 3, collect(10:10:100)),
        (0.01, 4, collect(10:10:200)),
        (0.01, 5, collect(10:10:300)),
    ]

    for (r, d, ns) in instances
        @info "Inputs: r: $r, d: $d"
        rng = MersenneTwister(seed)
        psn1 = [[rand(rng, n, d) for _ in 1:20] for n in ns]

        @info "Benchmarking Cell List"
        cl = stats(cell_list, psn1, r, measure)

        @info "Benchmarking Brute Force"
        psn2 = [psn[1:3] for psn in psn1]
        bf = stats(brute_force, psn2, r, measure)

        plt = plot(title="$measure | r: $r, d: $d", size=(720, 480), legend=:topleft)
        plot_data!(plt, ns, cl, "Cell List")
        plot_data!(plt, ns, bf, "Brute Force")

        directory = joinpath("figures", "cell_list_vs_brute_force")
        if !ispath(directory)
            mkpath(directory)
        end
        savefig(plt, joinpath(directory, "d$d-r$r-n$(ns[end]).svg"))
    end
end

function cell_list_dimensionality(seed::Int, measure::Measure)
    r = 0.05
    ds = [2, 3, 4, 5, 6]
    ns = collect(100:100:1000)
    rng = MersenneTwister(seed)

    plt = plot(title="$measure | r: $r", size=(720, 480), legend=:topleft)
    for d in ds
        @info "Inputs: r: $r, d: $d"
        psn = [[rand(rng, n, d) for _ in 1:1] for n in ns]

        @info "Benchmarking Cell List"
        cl = stats(cell_list, psn, r, measure)

        plot_data!(plt, ns, cl, "Cell List d: $d")
    end

    directory = joinpath("figures", "cell_list_dimensionality")
    if !ispath(directory)
        mkpath(directory)
    end
    savefig(plt, joinpath(directory, "r$r-n$(ns[end]).svg"))
end

seed = 894

true && cell_list_vs_brute_force(seed, time)
true && cell_list_dimensionality(seed, time)
