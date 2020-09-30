# CellLists.jl
[![Docs Image](https://img.shields.io/badge/docs-latest-blue.svg)](https://jaantollander.github.io/CellLists.jl/dev/)
[![Build Status](https://travis-ci.org/jaantollander/CellLists.jl.svg?branch=master)](https://travis-ci.org/jaantollander/CellLists.jl)

## Description
`CellLists.jl` is an algorithm that solves the fixed-radius near neighbors problem. That is, it finds all pairs of points that are within a fixed distance apart from each other.


## Installation
Currently, the package is unregistered. You can install it from GitHub.

```
pkg> add https://github.com/jaantollander/CellLists.jl
```


## Example
We can use `CellLists.jl` by supplying `n`, `d`-dimensional points, and fixed radius `r` to the `CellList` constructor.

```julia
using CellLists
n, d, r = 10, 2, 0.1
p = rand(n, d)
c = CellList(p, r)
```

By calling the `near_neighbors` function, we obtain a list of index pairs. A subset of the list contains the points that are within the given radius.

```julia
indices = near_neighbors(c)
```

```julia
[(3, 6), (4, 5)]  # indices
```

We can check if two points are within distance `r` as follows.

```julia
distance_condition(p1, p2, r) = (p1 .- p2).^2 ≤ r^2
```

We can iterate over neighboring points as follows.

```julia
for (i, j) in near_neighbors(c)
    if distance_condition(p[i, :], p[j, :], r)
        # (i, j) is a near neighbor
    end
end
```

We can compare Cell Lists to the brute force method.

```julia
for i in 1:(n-1)
    for j in (i+1):n
        if distance_condition(p[i, :], p[j, :], r)
            # (i, j) is a near neighbor
        end
    end
end
```

On average, the Cell List algorithm is more efficient than brute force when dimensions `d` is small, the number of points `n` is sufficiently large, and radius `r` is small compared to the bounding box of the points. Benchmarking section discusses how to benchmark instances to compare performances.


## Benchmarking
We can benchmark instances of Cell List agains brute force. First, we define the benchmarking functions.

```julia
using CellLists

@inline function distance_condition(p1::Vector{T}, p2::Vector{T}, r::T) where T <: AbstractFloat
    sum(@. (p1 - p2)^2) ≤ r^2
end

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
```

We will use [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl) for benchmarking.

```julia
using Random, BenchmarkTools
n, d, r = 100, 2, 0.01
p = rand(MersenneTwister(123), n, d)
```

Next, we run the benchmarks for `cell_list` and `brute_force` functions.

```julia
julia> t1 = @benchmark cell_list($p, $r)
BenchmarkTools.Trial:
  memory estimate:  47.11 KiB
  allocs estimate:  635
  --------------
  minimum time:     78.103 μs (0.00% GC)
  median time:      79.670 μs (0.00% GC)
  mean time:        82.669 μs (2.86% GC)
  maximum time:     2.702 ms (94.47% GC)
  --------------
  samples:          10000
  evals/sample:     1
```

```julia
julia> t2 = @benchmark brute_force($p, $r)
BenchmarkTools.Trial:
  memory estimate:  1.36 MiB
  allocs estimate:  14850
  --------------
  minimum time:     364.960 μs (0.00% GC)
  median time:      367.289 μs (0.00% GC)
  mean time:        397.621 μs (7.15% GC)
  maximum time:     1.579 ms (76.08% GC)
  --------------
  samples:          10000
  evals/sample:     1
```

We can compare the median execution times times and memory usage.

```julia
julia> ratio(median(t1), median(t2))
BenchmarkTools.TrialRatio:
  time:             0.21648868237276161
  gctime:           1.0
  memory:           0.03383838383838384
  allocs:           0.04276094276094276
```

```julia
julia> judge(median(t1), median(t2))
BenchmarkTools.TrialJudgement:
  time:   -78.35% => improvement (5.00% tolerance)
  memory: -96.62% => improvement (1.00% tolerance)
```

As we can see, Cell List performs much better on this instance than brute force.
