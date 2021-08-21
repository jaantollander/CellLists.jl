# CellLists.jl
[![DOI](https://zenodo.org/badge/298188925.svg)](https://zenodo.org/badge/latestdoi/298188925)
[![Docs Image](https://img.shields.io/badge/docs-stable-blue.svg)](https://jaantollander.github.io/CellLists.jl/stable/)
[![Runtests](https://github.com/jaantollander/CellLists.jl/workflows/Runtests/badge.svg)](https://github.com/jaantollander/CellLists.jl/actions/workflows/Runtests.yml)


## Description
**Cell Lists** is an algorithm that solves the fixed-radius near neighbors problem. That is, it finds all pairs of points that are within a fixed distance apart from each other. We can use the Cell Lists algorithm as a part of molecular dynamics or agent-based simulations where the interaction potential has a finite range.

You can read more about it in the article [**Searching for Fixed-Radius Near Neighbors with Cell Lists Algorithm in Julia Language**](https://jaantollander.com/post/searching-for-fixed-radius-near-neighbors-with-cell-lists-algorithm-in-julia-language/), which explores the Cell Lists algorithm and theory behind it more deeply. We also extended the algorithm to a multithreaded version, which we explain in the article [**Multithreading in Julia Language in Julia Language Applied to Cell Lists Algorithm**](https://jaantollander.com/post/multithreading-in-julia-language-applied-to-cell-lists-algorithm/).


## Citation
You can cite the `CellLists.jl` repository and code by navigating to the [**DOI**](https://zenodo.org/badge/latestdoi/298188925) provided by Zenodo and then choosing your preferred citation format from the *Export* section. For example, we can export [BibTex](https://zenodo.org/record/5075063/export/hx) format. Alternatively, you can use the *Cite This Repository* button below the *About* section in the right sidebar.


## Installation
You can install `CellLists.jl` with the Julia package manager.

```
pkg> add CellLists
```

Alternatively, you can install `CellLists.jl` directly from the GitHub repository.

```
pkg> add https://github.com/jaantollander/CellLists.jl
```


## Serial Algorithm
We can use `CellLists.jl` by supplying `n`, `d`-dimensional points, and fixed radius `r` to the `CellList` constructor.

```julia
using CellLists: CellList, near_neighbors, distance_condition
n, d, r = 10, 2, 0.1
p = rand(n, d)
c = CellList(p, r)
```

By calling the `near_neighbors` function, we obtain a list of index pairs of points that are within `r` distance.

```julia
indices = near_neighbors(c, p, r)
```

```julia
[(3, 6), (4, 5), ...]  # indices
```

We can compare Cell Lists to the brute force method.

```julia
indices2 = Vector{Tuple{Int, Int}}()
for i in 1:(n-1)
    for j in (i+1):n
        if distance_condition(p[i, :], p[j, :], r)
            push!(indices2, (i, j))
        end
    end
end
```

The outputs should be equal as follows:

```julia
@assert Set(Set.(indices)) == Set(Set.(indices2))
```

On average, the Cell List algorithm is more efficient than brute force when dimensions `d` is small, the number of points `n` is sufficiently large, and radius `r` is small compared to the bounding box of the points.


## Multithreaded Algorithm
We can use the multithreaded version of Cell Lists by dispatching with the `Val(:threads)` value type.

```julia
c = CellLists(p, r, Val(:threads))
```

```julia
near_neighbors(c, p, r, Val(:threads))
```


## Benchmarks
You can find the benchmarking code from the [**CellListsBenchmarks.jl**](https://github.com/jaantollander/CellListsBenchmarks.jl) repository and scripts for running the benchmarks and plotting in the [**cell-lists-benchmarks**](https://github.com/jaantollander/cell-lists-benchmarks) repository.
