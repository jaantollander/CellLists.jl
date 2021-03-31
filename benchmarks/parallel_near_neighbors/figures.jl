using JLD
using BenchmarkTools
using Plots

directory = "output/2021-03-31T11:29:17.606/parallel_near_neighbors/"
ispath(directory)
l = load(joinpath(directory, "results.jld"))
d, r, n = l["d"], l["r"], l["n"]
ts = l["ts"]
tp = l["tp"]

gettime(x) = getfield(x, :time)
ms = median.(ts)
mp = median.(tp)

p1 = plot(legend=false)
bar!(p1, gettime.(ms), alpha=0.5)
bar!(p1, gettime.(mp), alpha=0.5)

rsp = ratio.(ms, mp)
rt = gettime.(rsp)
p2 = scatter(rt, legend=false)
plot!(p2, 1:length(rt), fill(mean(rt), length(rt)))

# directory = figure_directory("parallel_near_neighbors")
savefig(p1, joinpath(directory, "d$d-r$r-n$n.svg"))
savefig(p2, joinpath(directory, "d$d-r$r-n$n-ratio.svg"))
