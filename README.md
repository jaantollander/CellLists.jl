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
n = 10
d = 2
r = 0.1
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

```julia
for (i, j) in indices
    if (p[i, :] .- p[j, :]).^2 ≤ r^2
        # ...
    end
end
```

On average, the Cell List algorithm is faster than brute force.
