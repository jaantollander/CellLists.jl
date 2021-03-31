using Base.Threads
using ArgParse
using Dates
using Random
using BenchmarkTools
using JLD
using CellLists

function benchmark(rng::AbstractRNG, n::Int, d::Int, r::Float64, iterations::Int, seconds::Float64)
    @info "Running benchmarks with:" n d r iterations nthreads()
    ts = BenchmarkTools.Trial[]
    tp = BenchmarkTools.Trial[]
    for i in 1:iterations
        @info "Iteration: $(i) / $(iterations) | Time: $(Time(now()))"
        p = rand(rng, n, d)
        c = CellList(p, r)
        bs = @benchmark near_neighbors($c, $p, $r) seconds=seconds
        bp = @benchmark p_near_neighbors($c, $p, $r) seconds=seconds
        push!(ts, bs)
        push!(tp, bp)
    end
    @info "Benchmarks finished: $(Time(now()))"
    return ts, tp
end

function output_dir(name::AbstractString; dirname::AbstractString="output")
    timestamp = string(now())
    directory = joinpath(dirname, timestamp, name)
    if !ispath(directory)
        mkpath(directory)
    end
    return directory
end

s = ArgParseSettings()
@add_arg_table s begin
    "--seed"
        default = 1
        arg_type = Int
    "--iterations", "-i"
        default = 1
        arg_type = Int
    "--seconds", "-s"
        default = 5.0
        arg_type = Float64
    "-n"
        default = 20000
        arg_type = Int
    "-d"
        default = 2
        arg_type = Int
    "-r"
        default = 0.01
        arg_type = Float64
    "--dir"
        default = "."
        arg_type = AbstractString
end
args = parse_args(s)

# Parameters
seed = args["seed"]
iterations = args["iterations"]
seconds = args["seconds"]
n = args["n"]
d = args["d"]
r = args["r"]

rng = MersenneTwister(seed)
ts, tp = benchmark(rng, n, d, r, iterations, seconds)
JLD.save(
    joinpath(args["dir"], output_dir("parallel_near_neighbors"), "results.jld"),
    "seed", seed, "iterations", iterations,
    "n", n, "d", d, "r", r,
    "ts", ts, "tp", tp,
    "nthreads", nthreads()
)
