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

On average, the Cell List algorithm is more efficient than brute force when dimensions `d` is small, the number of points `n` is sufficiently large, and radius `r` is small compared to the bounding box of the points.
