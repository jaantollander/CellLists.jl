# CellLists.jl
Documentation for CellLists.jl

## Serial
```@docs
CellList
CellList(::Array{T, 2}, ::T; ::Int) where T <: AbstractFloat
near_neighbors(::CellList, ::Array{T, 2}, ::T) where T <: AbstractFloat
```

## Multithreading
```@docs
merge(::CellList{d}, ::CellList{d}) where d
CellList(::Array{T, 2}, ::T, ::Val{:threads}) where T <: AbstractFloat
near_neighbors(::CellList{d}, ::Array{T, 2}, ::T, ::Val{:threads}) where d where T <: AbstractFloat
```
