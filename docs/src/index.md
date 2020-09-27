# CellLists.jl
Documentation for CellLists.jl

```@docs
CellList
CellList(::Array{T, 2}, ::T) where T <: AbstractFloat
Base.getindex(::CellList, ::CartesianIndex)
Base.CartesianIndices(::CellList)
Base.isempty(::CellList)
near_neighbors(::CellList)
```
