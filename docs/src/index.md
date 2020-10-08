# CellLists.jl
![](images/cell_list.svg)

Documentation for CellLists.jl

```@docs
CellList
CellList(::Array{T, 2}, ::T) where T <: AbstractFloat
near_neighbors(::CellList)
merge(::CellList{d}, ::CellList{d}) where d
```
