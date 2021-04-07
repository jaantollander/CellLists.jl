# CellLists.jl
![](docs/src/images/cell_list.svg)

[![Docs Image](https://img.shields.io/badge/docs-latest-blue.svg)](https://jaantollander.github.io/CellLists.jl/dev/)
![Runtests](https://github.com/jaantollander/CellLists.jl/workflows/Runtests/badge.svg)


## Description
`CellLists.jl` is an algorithm that solves the fixed-radius near neighbors problem. That is, it finds all pairs of points that are within a fixed distance apart from each other. Additionally, I wrote an article [**Searching for Fixed-Radius Near Neighbors with Cell Lists Algorithm in Julia Language**](https://jaantollander.com/post/searching-for-fixed-radius-near-neighbors-with-cell-lists-algorithm-in-julia-language/), which explores the Cell Lists algorithm and theory behind it more deeply.

[**Multithreading in Julia Language in Julia Language Applied to Cell Lists Algorithm**](https://jaantollander.com/post/multithreading-in-julia-language-applied-to-cell-lists-algorithm/)


## Installation
Currently, the package is unregistered. You can install it from GitHub.

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


## Multithreading
```julia
c = CellLists(p, r, Val(:parallel))
```

```julia
near_neighbors(c, p, r, Val(:parallel))
```


## Benchmarks
- [CellListsBenchmarks.jl](https://github.com/jaantollander/CellListsBenchmarks.jl)
- [cell-lists-benchmarks](https://github.com/jaantollander/cell-lists-benchmarks)
