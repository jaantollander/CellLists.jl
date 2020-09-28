# CellLists.jl
Documentation for CellLists.jl

```@docs
CellList
CellList(::Array{T, 2}, ::T) where T <: AbstractFloat
CartesianIndices(::CellList)
isempty(::CellList, ::CartesianIndex)
getindex(::CellList, ::CartesianIndex)
near_neighbors(::CellList)
```
