# CellLists.jl
Documentation for CellLists.jl

```@docs
CellList
CellList(::Array{T, 2}, ::T) where T <: AbstractFloat
getindex(::CellList, ::CartesianIndex)
CartesianIndices(::CellList)
isempty(::CellList, ::CartesianIndex)
near_neighbors(::CellList)
```
