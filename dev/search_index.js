var documenterSearchIndex = {"docs":
[{"location":"#CellLists.jl","page":"CellLists.jl","title":"CellLists.jl","text":"","category":"section"},{"location":"","page":"CellLists.jl","title":"CellLists.jl","text":"Documentation for CellLists.jl","category":"page"},{"location":"","page":"CellLists.jl","title":"CellLists.jl","text":"CellList\nCellList(::Array{T, 2}, ::T) where T <: AbstractFloat\nnear_neighbors(::CellList)","category":"page"},{"location":"#CellLists.CellList","page":"CellLists.jl","title":"CellLists.CellList","text":"CellList type. The indices dictionary maps the CartesianIndex of each cell to the indices of points in that cell.\n\n\n\n\n\n","category":"type"},{"location":"#CellLists.CellList-Union{Tuple{T}, Tuple{Array{T,2},T}} where T<:AbstractFloat","page":"CellLists.jl","title":"CellLists.CellList","text":"Construct CellList from points p and radius r>0.\n\nExamples\n\nn, d, r = 100, 2, 0.01\np = rand(n, d)\nc = CellLists(p, r)\n\n\n\n\n\n","category":"method"},{"location":"#CellLists.near_neighbors-Tuple{CellList}","page":"CellLists.jl","title":"CellLists.near_neighbors","text":"Return a vector of all pairs that are in neighboring cells in the cell list.\n\nExamples\n\njulia> near_neighbors(c)\n[(1, 4), (3, 11), ...]\n\n\n\n\n\n","category":"method"}]
}
