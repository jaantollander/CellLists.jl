# CellLists.jl
![](images/cell_list.svg)

Documentation for CellLists.jl

## Serial
```@docs
CellList
CellList(::Array{T, 2}, ::T) where T <: AbstractFloat
near_neighbors(::CellList, ::Array{T, 2}, ::T) where T <: AbstractFloat
```

## Parallel
```@docs
merge(::CellList{d}, ::CellList{d}) where d
CellList(::Array{T, 2}, ::T, ::Val{:parallel}) where T <: AbstractFloat
p_near_neighbors(::CellList{d}, ::Array{T, 2}, ::T) where d where T <: AbstractFloat
```
